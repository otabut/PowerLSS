<#
.SYNOPSIS
	Startup scripts Powershell management tool

.DESCRIPTION
	
.LINK
	https://github.com/otabut/PowerLSS

.NOTES
    Author: Olivier TABUT
	Version: 0.1.0 (14/01/2018)
    ChangeLog: 
       Initial version (14/01/2018)

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


### DECLARE FUNCTIONS ###

Function Write-Log
{
  Param (
    [parameter(Mandatory=$true)][String]$Step,
    [parameter(Mandatory=$true)][ValidateSet("Information","Warning","Error")][String]$Status,
    [parameter(Mandatory=$true)][String]$Comment
  )

  #Format message to log
  $Date = Get-Date -format "dd/MM/yyyy HH:mm:ss.fff"
  $Message = "$Date - $Hostname - $Step - $Status - $Comment"
  
  #Handle Console Output
  if ($ConsoleOutput.IsPresent)
  {
    switch ($Status)
    {
      "Information"
      { 
        Write-Host $Message
      }
      "Warning"
      { 
        Write-Host $Message -ForegroundColor Yellow
      }
      "Error"
      { 
        Write-Host $Message -ForegroundColor Red
      }
    }
  }

  #Handle writing in log file
  if ($LogFile)
  {
    Add-Content $Logfile $Message
  }

  #Handle returned PSCustomObject
  if (($Output.IsPresent) -or ($CustomLogging.IsPresent))
  {
    $Line = [PSCustomObject]@{
      Date = $Date
      Hostname = $HostName
      Step = $Step
      Status = $Status
      Comment = $Comment
    }
    $script:Log += $Line
  }

  #Handle custom logging function
  if ($CustomLogging.IsPresent)
  {
    Start-LSSCustomLogging $Line
  }
}

Function Move-File($File,$Target)
{
  #Test existence of folder and create it if missing
  if (!(Test-Path -Path $Target))
  {
    New-Item -Path $Target -ItemType Directory | out-null
  }
  #Move script that has been processed
  Move-Item $File $Target -Force
}


### MAIN SECTION ###

#Import PowerLSS helper module
Import-Module "$($PSScriptRoot)\PowerLSS-Helper\PowerLSS-Helper.psm1"

$ErrorActionPreference = "stop"
Try
{
  #Variables
  $Script:Log = @()
  $Global:HostName = $env:computername
  $Global:ScriptsPath = "$($PSScriptRoot)\PostInstall"
  
  Write-Log -Step "Initialize" -Status "Information" -Comment "Start of processing."
  if ($InitialDelay)
  {
    Write-Log -Step "Initialize" -Status "Information" -Comment "Waiting for $InitialDelay seconds before performing any actions..."
    Start-Sleep $InitialDelay
  }
  
  #Launch function to handle pre actions
  if (!($DontRunPreActions.IsPresent))
  {
    Start-LSSPreActions
  }

  #Get the list of scripts to execute
  $ScriptFile = Get-ChildItem $ScriptsPath -File | Sort Name | Select -first 1
  
  while ($ScriptFile)
  {
    $ScriptFullName = $ScriptFile.FullName
    $ScriptName = $ScriptFile.Name
    $ScriptBaseName = $ScriptFile.BaseName
    $ScriptExtension = $ScriptFile.Extension.Replace('.','').ToUpper()
    
    #Start script
    Write-Log -Step "Process" -Status "Information" -Comment "Processing $ScriptBaseName"

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

    if (!($ToSkip) -and (Get-Command -Name Start-$ScriptExtension`Script -errorAction SilentlyContinue))
    {
      $Result = & "Start-$ScriptExtension`Script" -Script "$ScriptFullName"
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
        #Write-Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Status : $ReturnStatus"
        #Write-Log -Step "Processing $ScriptBaseName" -Status "Information" -Comment "Return Code : $ReturnCode"
        Write-Log -Step "Process" -Status "Information" -Comment "$ScriptName processed successfully"
        Move-File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"

        #Test if a shutdown or a restart has been requested
        if ($RebootRequested)
        {
          if ($AllowReboot.IsPresent)
          {
            Write-Log -Step "Process" -Status "Information" -Comment "Computer reboot has been requested"
            Restart-Computer -Force
            Break
          }
          else
          {
            Write-Log -Step "Process" -Status "Information" -Comment "Computer reboot has been requested but reboot not currently allowed"
            if ($ContinueIfRebootRequest.IsPresent)
            {
              Write-Log -Step "Process" -Status "Information" -Comment "Allowed to continue despite reboot request"
              $RebootRequested = $False
            }
            else
            {
              Write-Log -Step "Process" -Status "Information" -Comment "Not allowed to continue because of reboot request. Stopping."
            }
          }
        }
      }
      "Warning"
      {
        $ProcessRetry = $false
        Write-Log -Step "Processing $ScriptBaseName" -Status "Warning" -Comment "Return Status : $ReturnStatus"
        Write-Log -Step "Processing $ScriptBaseName" -Status "Warning" -Comment "Return Code : $ReturnCode"
        Write-Log -Step "Processing $ScriptBaseName" -Status "Warning" -Comment "Return Message : $ReturnMessage"
        Write-Log -Step "Process" -Status "Warning" -Comment "$ScriptBaseName processed with some warnings. Please check."
	Start-LSSWarningActions
        Move-File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
      }
      "Failure"
      {
        Write-Log -Step "Processing $ScriptBaseName" -Status "Error" -Comment "Return Status : $ReturnStatus"
        Write-Log -Step "Processing $ScriptBaseName" -Status "Error" -Comment "Return Code : $ReturnCode"
        Write-Log -Step "Processing $ScriptBaseName" -Status "Error" -Comment "Return Message : $ReturnMessage"

        #Script failure, raise error and either make a retry or abort 
        if ($ProcessRetry)
        {
          $ProcessRetry = $false
          Write-Log -Step "Process" -Status "Error" -Comment "$ScriptName has failed after 2 attempts. Please check error message."
          #Launch function to handle actions when failure
          Start-LSSFailureActions
          if ($ContinueOnFailure.IsPresent)
          {
            Write-Log -Step "Process" -Status "Information" -Comment "Continue on failure is active, moving on"
            Move-File -File $ScriptFullName -Target "$ScriptsPath\Done"
            Write-Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
          }
        }
        else
        {
          if ($Retry.IsPresent)
          {
            Write-Log -Step "Process" -Status "Error" -Comment "$ScriptName has failed once, trying one more time"
            $ProcessRetry = $true
          }
          else
          {
            Write-Log -Step "Process" -Status "Error" -Comment  "$ScriptName has failed, no retry. Please check error message."
            #Launch function to handle actions to run when failure
            Start-LSSFailureActions
            if ($ContinueOnFailure.IsPresent)
            {
              Write-Log -Step "Process" -Status "Information" -Comment "Continue on failure is active, moving on"
              Move-File -File $ScriptFullName -Target "$ScriptsPath\Done"
              Write-Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
            }
          }
        }
      }
      Default
      {
        Write-Log -Step "Process" -Status "Warning" -Comment "$ScriptName provide unsupported return status : $ReturnStatus"
        Move-File -File $ScriptFullName -Target "$ScriptsPath\Done"
        Write-Log -Step "Process" -Status "Information" -Comment "$ScriptName has been moved"
      }
    }
     
    if (!($RebootRequested) -and (($ReturnStatus -ne "Failure") -or ($ContinueOnFailure.IsPresent)))
    {
      #Get next script to run
      $ScriptFile = Get-ChildItem $ScriptsPath -File | sort Name | select -first 1
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
    Write-Log -Step "Finalize" -Status "Information" -Comment "No more script to run"
    #Launch function to handle actions to run when success
    Start-LSSSuccessActions
    #Disable scheduled task if requested
    if ($DisableAtTheEnd.IsPresent)
    {
      SCHTASKS /CHANGE /DISABLE /TN Lanceur
      Write-Log -Step "Finalize" -Status "Information" -Comment "Scheduled task has been disabled"
    }
  }
  
  #Launch function to handle post actions
  if (!($DontRunPostActions.IsPresent))
  {
    Start-LSSPostActions
  }

  Write-Log -Step "Finalize" -Status "Information" -Comment "End of processing"

  if ($Output.IsPresent)
  {
    $script:Log | ft
  }
}    
Catch
{
  $ErrorMessage = $_.Exception.Message
  $ErrorLine = $_.InvocationInfo.ScriptLineNumber
  Write-Log -Step "Error Management" -Status "Error" -Comment "Error on line $ErrorLine. The error message was: $ErrorMessage"
  Start-LSSFailureActions
}

