<#
.SYNOPSIS
    Startup scripts Powershell management tool

.DESCRIPTION
	
.LINK
    https://github.com/otabut/PowerLSS

.NOTES
    Author: Olivier TABUT
        0.3.0 release (28/01/2018)
    ChangeLog: 
        Initial version (14/01/2018)
        0.2.0 release (21/01/2018)
	0.3.0 release (28/01/2018)

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

.PARAMETER ValidExitCodes
    List of valid exit codes from startup scripts (comma separated)

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

.EXAMPLE
    Lanceur

.EXAMPLE
    Lanceur -Retry -Reboot -Include 'ps1' -InitialDelay 60 -ConsoleOutput

.EXAMPLE
    Lanceur -Exclude 'bat' -InitialDelay 30 -DisableAtTheEnd -LogFile C:\TEMP\PowerLSS.log
#>

  Param (
    [parameter(Mandatory=$false)][Switch]$Retry,
    [parameter(Mandatory=$false)][Switch]$AllowReboot,
    [parameter(Mandatory=$false)][Switch]$ContinueIfRebootRequest,
    [parameter(Mandatory=$false)][Switch]$ContinueOnFailure,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Include,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Exclude,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][Int]$InitialDelay,
    [parameter(Mandatory=$false)][Switch]$DisableAtTheEnd,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$ValidExitCodes,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$LogFile,
    [parameter(Mandatory=$false)][Switch]$ConsoleOutput,
    [parameter(Mandatory=$false)][Switch]$Output,
    [parameter(Mandatory=$false)][Switch]$CustomLogging,
    [parameter(Mandatory=$false)][Switch]$DontRunPreActions,
    [parameter(Mandatory=$false)][Switch]$DontRunPostActions
  )


### MAIN SECTION ###

$ErrorActionPreference = "stop"
Try
{
  #Import PowerLSS helper module
  Import-Module PowerLSS
  
  #Variables
  $Global:Log = @()
  $Script:ScriptsPath = "$($PSScriptRoot)\PostInstall"

  #Redefine scope of parameters used by other cmdlets
  $Global:LogFile = $LogFile
  $Global:ConsoleOutput = $ConsoleOutput
  $Global:Output = $Output
  $Global:CustomLogging = $CustomLogging

  #Initialize
  Write-LSS_Log -Step "Initialize" -Status "Information" -Comment "Start of processing."
  Write-LSS_Log -Step "General" -Status "Information" -Comment "Arguments : $($MyInvocation.BoundParameters.keys -join ',')"
  if ($InitialDelay)
  {
    Write-LSS_Log -Step "Initialize" -Status "Information" -Comment "Waiting for $InitialDelay seconds before performing any actions..."
    Start-Sleep $InitialDelay
  }
  
  #Launch function to handle pre actions
  if (!($DontRunPreActions.IsPresent))
  {
    Start-LSS_PreActions
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
      $ReturnStatus = "Warning"
      $ReturnMessage = "Ignored - file extension not supported"
    }

    switch ($ReturnStatus)
    {
      "Success"  #If success, move script and process next one or exit
      {
        $ProcessRetry = $false
        #Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Status : $ReturnStatus"
        #Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Code : $ReturnCode"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName processed successfully"
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"

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
        Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Warning" -Comment "Return Status : $ReturnStatus"
        Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Warning" -Comment "Return Code : $ReturnCode"
        Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Warning" -Comment "Return Message : $ReturnMessage"
        Write-LSS_Log -Step "Process" -Status "Warning" -Comment "$ScriptBaseName processed with some warnings. Please check."
        Start-LSS_WarningActions
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
      }
      "Failure"
      {
        Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Error" -Comment "Return Status : $ReturnStatus"
        Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Error" -Comment "Return Code : $ReturnCode"
        Write-LSS_Log -Step "Processing $ScriptBaseName" -Status "Error" -Comment "Return Message : $ReturnMessage"

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
            Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
            Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
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
              Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
              Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
            }
          }
        }
      }
      Default
      {
        Write-LSS_Log -Step "Process" -Status "Warning" -Comment "$ScriptName provide unsupported return status : $ReturnStatus"
        Move-LSS_File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-LSS_Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
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
      Disable-LSS_ScheduledTask
      Write-LSS_Log -Step "Finalize" -Status "Information" -Comment "Scheduled task has been disabled"
    }
  }
  
  #Launch function to handle post actions
  if (!($DontRunPostActions.IsPresent))
  {
    Start-LSS_PostActions
  }

  Write-LSS_Log -Step "Finalize" -Status "Information" -Comment "End of processing"

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

