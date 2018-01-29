Function Install-PowerLSS
{
  <#
  .SYNOPSIS
      Script for installing PowerLSS scheduled task

  .DESCRIPTION
	
  .PARAMETER Force
      Delete any previous scheduled task if exists before creating it

  .PARAMETER NoStart
      Prevent from starting PowerLSS scheduled task after initial installation

  .PARAMETER LogFile
      Activate logging to a file and define path to the log file

  .PARAMETER ConsoleOutput
      Display logs in console

  .PARAMETER Output
      Return logs as a Powershell object

  .PARAMETER CustomLogging
      Activate custom logging function (write to Event Logs, Syslog, Database, ...)

  .EXAMPLE
      ./Install-PowerLSS.ps1

  .EXAMPLE
      ./Install-PowerLSS.ps1 -Force -NoStart
  #>

  Param (
    [parameter(Mandatory=$false)][Switch]$Force,
    [parameter(Mandatory=$false)][Switch]$NoStart,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$LogFile,
    [parameter(Mandatory=$false)][Switch]$ConsoleOutput,
    [parameter(Mandatory=$false)][Switch]$Output,
    [parameter(Mandatory=$false)][Switch]$CustomLogging
  )

  ### MAIN SECTION ###
  
  $ErrorActionPreference = "stop"
  Try
  {
    #Import PowerLSS helper module
    If (!(Get-module PowerLSS))
    {
      Import-Module PowerLSS
    }

    #Variables
    $Global:Log = @()

    #Redefine scope of parameters used by other cmdlets
    $Global:LogFile = $LogFile
    $Global:ConsoleOutput = $ConsoleOutput
    $Global:Output = $Output
    $Global:CustomLogging = $CustomLogging
  
    #Initialize
    Write-LSS_Log -Step "General" -Status "Information" -Comment "Start of processing"
    Write-LSS_Log -Step "General" -Status "Information" -Comment "Arguments : $($MyInvocation.BoundParameters.keys -join ',')"
    
    #Check for previous PowerLSS scheduled task
    Write-LSS_Log -Step "Check" -Status "Information" -Comment "Check if PowerLSS scheduled task already exists"
    if ((Get-LSS_ScheduledTask).State -eq 'Not installed')
    {
      Write-LSS_Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task doesn't exist yet"
      $DoInstall = $true
    }
    else
    {
      $AlreadyExists = $true
      Write-LSS_Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task already exists"
      if ($Force.IsPresent)
      {
        Write-LSS_Log -Step "Setup" -Status "Information" -Comment "Trying to remove PowerLSS scheduled task"
        $Command = Remove-LSS_ScheduledTask
        if (($Command.Result -eq 'Success') -and ((Get-LSS_ScheduledTask).State -eq 'Not installed'))
        {
          Write-LSS_Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task removed successfully"
          $DoInstall = $true
        }
        else
        {
          Write-LSS_Log -Step "Setup" -Status "Error" -Comment "PowerLSS scheduled task cannot be removed"
        }
      }
      else
      {
        Write-LSS_Log -Step "Check" -Status "Information" -Comment "No need to update PowerLSS scheduled task"
        $DoInstall = $false
      }
    }
  
    #Install PowerLSS scheduled task
    if ($DoInstall)
    {
      Write-LSS_Log -Step "Setup" -Status "Information" -Comment "Processing PowerLSS scheduled task setup"
      $Result = (Register-LSS_ScheduledTask).Result
      Stop-LSS_ScheduledTask  ###### needed because of known issue with W2K8R2 only ######
      $State = (Get-LSS_ScheduledTask).State
      if (($Result -eq 'Success') -and ($State -eq 'Ready'))
      {
        Write-LSS_Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task installed successfully"
        $DoStart = $true
      }
      else
      {
        Write-LSS_Log -Step "Setup" -Status "Error" -Comment "Problem during PowerLSS scheduled task setup : $Result - $State"
        $DoStart = $false
      }
    }
    else
    {
      #Check status of PowerLSS scheduled task
      if ($AlreadyExists)
      {
        Write-LSS_Log -Step "Check" -Status "Information" -Comment "Checking PowerLSS scheduled task status"
        $State = (Get-LSS_ScheduledTask).State
        if ($State -eq 'Ready')
        {
          Write-LSS_Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task is ready to run"
          $DoStart = $true
        }
        elseif ($State -eq 'Disabled')
        {
          Write-LSS_Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task is disabled, trying to enable it"
          if ((Enable-LSS_ScheduledTask).Result -eq 'Success')
          {
            Write-LSS_Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task was enabled successfully"
            $DoStart = $true
          }
          else
          {
            Write-LSS_Log -Step "Check" -Status "Error" -Comment "PowerLSS scheduled task cannot be enabled"
            $DoStart = $false
          }
        }
        else
        {
          Write-LSS_Log -Step "Check" -Status "Error" -Comment "PowerLSS scheduled task is already running, so trying to stop it"
          if ((Stop-LSS_ScheduledTask).Result -eq 'Success')
          {
            Write-LSS_Log -Step "Check" -Status "Error" -Comment "PowerLSS scheduled task is ready to run as it was stopped successfully"
            $DoStart = $true
          }
          else
          {
            Write-LSS_Log -Step "Check" -Status "Error" -Comment "PowerLSS scheduled task cannot be stopped"
            $DoStart = $false
          }
        }
      }
    }

    #Start PowerLSS scheduled task
    if ($NoStart.IsPresent)
    {
      Write-LSS_Log -Step "Startup" -Status "Information" -Comment "NoStart switch is present, so skipping startup"
      $DoStart = $false
    }
    if ($DoStart)
    {
      Write-LSS_Log -Step "Startup" -Status "Information" -Comment "Processing PowerLSS scheduled task startup"
      $Command = Start-LSS_ScheduledTask
      if ($Command.Result -eq 'Success')
      {
        Write-LSS_Log -Step "Startup" -Status "Information" -Comment "PowerLSS scheduled task started successfully"
      }
      else
      {
        Write-LSS_Log -Step "Startup" -Status "Error" -Comment "PowerLSS scheduled task cannot be started"
      }
    }

    Write-LSS_Log -Step "General" -Status "Information" -Comment "End of processing"

    if ($Output.IsPresent)
    {
      $Global:Log | ft
    }
  }
  Catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-LSS_Log -Step "Error Management" -Status "Error" -Comment "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}

