<#
.SYNOPSIS
    Startup scripts Powershell management tool

.DESCRIPTION
	
.LINK
    https://github.com/otabut/PowerLSS

.NOTES
    Author: Olivier TABUT
    0.5.0 release (03/02/2018)

.PARAMETER Retry
    Activate a retry if first attempt to run startup script failed

.PARAMETER AllowReboot
    Allow reboot if requested by startup script

.PARAMETER ContinueIfRebootRequest
    Allow to continue running startup scripts if reboot has been requested but not allowed

.PARAMETER ContinueOnFailure
    If a startup script fails, then continue

.PARAMETER Include
    Explicitely define supported file extensions for startup scripts (comma separated)

.PARAMETER Exclude 
    Explicitely define unsupprted file extensions for startup scripts (comma separated)

.PARAMETER InitialDelay
    Initial delay in seconds before start processing startup scripts

.PARAMETER DisableAtTheEnd
    Disable scheduled task when all startup scripts have been successfully processed

.PARAMETER LogFile
    Activate logging to a file and define path to the log file

.PARAMETER ConsoleOutput
    Display logs in console

.PARAMETER Output
    Return logs as a Powershell object

.PARAMETER CustomLogging
    Activate custom logging function (write to Event Logs, Syslog, Database, ...)

.PARAMETER DontRunPreActions
    Prevent pre actions from running

.PARAMETER DontRunPostActions
    Prevent post actions from running

.PARAMETER ScriptsFolder
    Name of the folder where scripts are located. Must NOT be an absolute or relative path, must be just a folder name. Default is 'PostInstall' but allows to have multiple scripts sets.

.PARAMETER ConfigurationName
    Name of the predefined configuration to use
    
.PARAMETER CurrentConfiguration
    Will use the configuration defined as current

.EXAMPLE
    .\PowerLSS.ps1

.EXAMPLE
    .\PowerLSS.ps1 -Retry -Reboot -Include 'ps1' -InitialDelay 60 -ConsoleOutput

.EXAMPLE
    .\PowerLSS.ps1 -Exclude 'bat' -InitialDelay 30 -DisableAtTheEnd -LogFile C:\TEMP\PowerLSS.log

.EXAMPLE
    .\PowerLSS.ps1 -ConfigurationName 'Default'
#>

  Param (
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$Retry,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$AllowReboot,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$ContinueIfRebootRequest,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$ContinueOnFailure,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][ValidateNotNull()][String]$Include,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][ValidateNotNull()][String]$Exclude,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][ValidateNotNullOrEmpty()][Int]$InitialDelay,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$DisableAtTheEnd,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][ValidateNotNullOrEmpty()][String]$LogFile,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$ConsoleOutput,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$Output,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$CustomLogging,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$DontRunPreActions,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][Switch]$DontRunPostActions,
    [parameter(Mandatory=$false,ParameterSetName="Standard")][ValidateNotNullOrEmpty()][String]$ScriptsFolder='PostInstall',
    [parameter(Mandatory=$true,ParameterSetName="Specific")][ValidateNotNullOrEmpty()][String]$ConfigurationName,
    [parameter(Mandatory=$true,ParameterSetName="Current")][Switch]$CurrentConfiguration
  )


### MAIN SECTION ###

$ErrorActionPreference = "stop"
Try
{
  #Import PowerLSS module
  If (!(Get-module PowerLSS))
  {
    Import-Module PowerLSS
  }
  #Import PowerLSS helper functions
  ForEach ($Function in Get-ChildItem -Path "$($PSScriptRoot)\Helpers\*.ps1" -Recurse)
  {
    . $Function.FullName
  }
  
  #Check on ParameterSet
  switch ($PSCmdlet.ParameterSetName)
  {
    "Standard"
    {
      #Redefine scope of parameters used by other cmdlets
      $Global:LogFile = $LogFile
      $Global:ConsoleOutput = $ConsoleOutput
      $Global:Output = $Output
      $Global:CustomLogging = $CustomLogging
    }
    "Specific"
    {
      #Retrieve configuration
      $Config = Get-LSS_Configuration -ConfigurationName $ConfigurationName -Quiet
      #Redefine scope of parameters used by other cmdlets
      $Global:LogFile = $Config.LogFile
      $Global:ConsoleOutput = ($Config.ConsoleOutput -eq "True")
      $Global:Output = ($Config.Output -eq "True")
      $Global:CustomLogging = ($Config.CustomLogging -eq "True")
      $Retry = ($Config.Retry -eq "True")
      $AllowReboot = ($Config.AllowReboot -eq "True")
      $ContinueIfRebootRequest = ($Config.ContinueIfRebootRequest -eq "True")
      $ContinueOnFailure = ($Config.ContinueOnFailure -eq "True")
      $Include = "$($Config.Include)"
      $Exclude = "$($Config.Exclude)"
      $InitialDelay = $Config.InitialDelay
      $DisableAtTheEnd = ($Config.DisableAtTheEnd -eq "True")
      $DontRunPreActions = ($Config.DontRunPreActions -eq "True")
      $DontRunPostActions = ($Config.DontRunPostActions -eq "True")
      $ScriptsFolder = "$($Config.ScriptsFolder)"
    }
    "Current"
    {
      #Retrieve configuration
      $Config = Get-LSS_Configuration -Current -Quiet
      #Redefine scope of parameters used by other cmdlets
      $Global:LogFile = $Config.LogFile
      $Global:ConsoleOutput = ($Config.ConsoleOutput -eq "True")
      $Global:Output = ($Config.Output -eq "True")
      $Global:CustomLogging = ($Config.CustomLogging -eq "True")
      $Retry = ($Config.Retry -eq "True")
      $AllowReboot = ($Config.AllowReboot -eq "True")
      $ContinueIfRebootRequest = ($Config.ContinueIfRebootRequest -eq "True")
      $ContinueOnFailure = ($Config.ContinueOnFailure -eq "True")
      $Include = "$($Config.Include)"
      $Exclude = "$($Config.Exclude)"
      $InitialDelay = $Config.InitialDelay
      $DisableAtTheEnd = ($Config.DisableAtTheEnd -eq "True")
      $DontRunPreActions = ($Config.DontRunPreActions -eq "True")
      $DontRunPostActions = ($Config.DontRunPostActions -eq "True")
      $ScriptsFolder = "$($Config.ScriptsFolder)"
    }
  }

  #Variables
  $Global:Log = @()
  $Script:ScriptsPath = "$($PSScriptRoot)\$ScriptsFolder"

  #Launch function to handle pre actions
  if (!($DontRunPreActions.IsPresent))
  {
    Start-LSS_PreActions
  }

  #Initialize
  Write-LSS_Log -Step "Initialize" -Status "Information" -Comment "Start of processing."
  Write-LSS_Log -Step "General" -Status "Information" -Comment "Arguments : $($MyInvocation.BoundParameters.keys -join ',')"
  if ($InitialDelay)
  {
    Write-LSS_Log -Step "Initialize" -Status "Information" -Comment "Waiting for $InitialDelay seconds before performing any actions..."
    Start-Sleep $InitialDelay
  }
  
  #Get the list of scripts to execute
  $FirstRun = $true  #Boolean to prevent from computer restart loop
  $ScriptList = Get-ChildItem $ScriptsPath -File | Sort Name
  $ScriptCount = $ScriptList.Count
  Write-LSS_Log -Step "Process" -Status "Information" -Comment "Found $ScriptCount script(s) to run"
  $ScriptFile = $ScriptList | Select -first 1
  
  while ($ScriptFile)
  {
    $ScriptFullName = $ScriptFile.FullName
    $ScriptName = $ScriptFile.Name
    $ScriptBaseName = $ScriptFile.BaseName
    $ScriptExtension = $ScriptFile.Extension.Replace('.','').ToUpper()
    
    #Start script
    Write-LSS_Log -Step "Process" -Status "Information" -Comment "Processing $ScriptBaseName"

    #Handle Include/Exclude
    $ToSkip = $False
    if (!([string]::IsNullOrEmpty($Include)) -and (!($Include -match $ScriptExtension)))
    {
      $ToSkip = $True
    }
    if (!([string]::IsNullOrEmpty($Exclude)) -and ($Exclude -match $ScriptExtension))
    {
      $ToSkip = $True
    }

    if (!($ToSkip) -and (Get-Command -Name Start-LSS_$ScriptExtension`Script -errorAction SilentlyContinue))
    {
      $Result = & "Start-LSS_$ScriptExtension`Script" -Script "$ScriptFullName"
      $ReturnCode = $Result.Code
      $ReturnStatus = $Result.Status
      $ReturnMessage = $Result.Message
      $RebootRequested = $Result.RebootRequested
    }
    else
    {
      $ReturnCode = "0"
      $ReturnStatus = "Skipped"
      $ReturnMessage = "Ignored - file extension not supported"
      $RebootRequested = $False
    }

    Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Status : $ReturnStatus"
    Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Code : $ReturnCode"
    Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Message : $ReturnMessage"
    Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Reboot Requested ? $RebootRequested"

    switch ($ReturnStatus)
    {
      "Success"  #If success, move script and process next one or exit
      {
        $ProcessRetry = $false
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName processed successfully"
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved to Done folder"

        #Test if a shutdown or a restart has been requested
        if ($RebootRequested)
        {
          if ($AllowReboot.IsPresent)
          {
            Write-LSS_Log -Step "Process" -Status "Information" -Comment "Computer reboot has been requested"
	        if ($FirstRun)
	        {
	          $RebootRequested = $False
	          Write-LSS_Log -Step "Process" -Status "Warning" -Comment "Computer reboot has been requested but this is first startup script so reboot is skipped"
	        }
	        else
	        {
              Restart-Computer -Force
              Break
	        }
          }
          else
          {
            Write-LSS_Log -Step "Process" -Status "Information" -Comment "Computer reboot has been requested but reboot not currently allowed"
            if ($ContinueIfRebootRequest.IsPresent)
            {
              Write-LSS_Log -Step "Process" -Status "Information" -Comment "Allowed to continue despite reboot request"
              $RebootRequested = $False
            }
            else
            {
              Write-LSS_Log -Step "Process" -Status "Information" -Comment "Not allowed to continue because of reboot request. Stopping."
            }
          }
        }
      }
      "Warning"
      {
        $ProcessRetry = $false
        Write-LSS_Log -Step "Process" -Status "Warning" -Comment "$ScriptBaseName processed with some warnings. Please check."
        Start-LSS_WarningActions
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved to Done folder"
      }
      "Failure"
      {
        #Script failure, raise error and either make a retry or abort 
        if ($ProcessRetry)
        {
          $ProcessRetry = $false
          Write-LSS_Log -Step "Process" -Status "Error" -Comment "$ScriptName has failed after 2 attempts. Please check error message."
          #Launch function to handle actions when failure
          Start-LSS_FailureActions
          if ($ContinueOnFailure.IsPresent)
          {
            Write-LSS_Log -Step "Process" -Status "Information" -Comment "Continue on failure is active, moving on"
            Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Failed"
            Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved to Failed folder"
          }
        }
        else
        {
          if ($Retry.IsPresent)
          {
            Write-LSS_Log -Step "Process" -Status "Error" -Comment "$ScriptName has failed once, trying one more time"
            $ProcessRetry = $true
          }
          else
          {
            Write-LSS_Log -Step "Process" -Status "Error" -Comment  "$ScriptName has failed, no retry. Please check error message."
            #Launch function to handle actions to run when failure
            Start-LSS_FailureActions
            if ($ContinueOnFailure.IsPresent)
            {
              Write-LSS_Log -Step "Process" -Status "Information" -Comment "Continue on failure is active, moving on"
              Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Failed"
              Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved to Failed folder"
            }
          }
        }
      }
      "Skipped"
      {
        Write-LSS_Log -Step "Process" -Status "Warning" -Comment "$ScriptName was skipped because of unsupported file extension"
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Skipped"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved to Skipped folder"
      }
      Default
      {
        Write-LSS_Log -Step "Process" -Status "Warning" -Comment "$ScriptName provide unsupported return status : $ReturnStatus"
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Skipped"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved to Skipped folder"
      }
    }
     
    if (!($RebootRequested) -and (($ReturnStatus -ne "Failure") -or ($ContinueOnFailure.IsPresent)))
    {
      #Get next script to run
      $FirstRun = $false  #Boolean to prevent from computer restart loop
      $ScriptList = Get-ChildItem $ScriptsPath -File | Sort Name
      $ScriptCount = $ScriptList.Count
      Write-LSS_Log -Step "Process" -Status "Information" -Comment "Found $ScriptCount script(s) left to run"
      $ScriptFile = $ScriptList | Select -first 1
    }
    elseif ($ProcessRetry)
    {
      #Do nothning, just loop one more time
    }
    else
    {
      #Exit loop in case of failure or reboot
      break
    }
  }

  #Finalize if all scripts are in success
  if (!($RebootRequested) -and ($ReturnStatus -ne "Failure"))
  {
    Write-LSS_Log -Step "Finalize" -Status "Information" -Comment "No more script to run, ready to perform end-up tasks"
    #Launch function to handle actions to run when success
    Start-LSS_SuccessActions
    #Disable scheduled task if requested
    if ($DisableAtTheEnd.IsPresent)
    {
      if ((Disable-LSS_ScheduledTask).Result)
      {
        Write-LSS_Log -Step "Finalize" -Status "Information" -Comment "Scheduled task has been disabled"
      }
      else
      {
        Write-LSS_Log -Step "Finalize" -Status "Error" -Comment "Cannot disable scheduled task"
      }
    }
  }
  
  Write-LSS_Log -Step "Finalize" -Status "Information" -Comment "End of processing"

  #Launch function to handle post actions
  if (!($DontRunPostActions.IsPresent))
  {
    Start-LSS_PostActions
  }

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
  Start-LSS_FailureActions
}

