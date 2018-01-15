<#
.SYNOPSIS
    Script for installing PowerLSS scheduled task

.DESCRIPTION
	
.LINK
    https://github.com/otabut/PowerLSS

.NOTES
    Author: Olivier TABUT
        Version: 0.2.0 (21/01/2018)
    ChangeLog: 
        Initial version (14/01/2018)
	0.2.0 release (21/01/2018)
	
.PARAMETER ForceCreate
    Delete any previous scheduled task if exists

.EXAMPLE
    ./Install-PowerLSS.ps1

.EXAMPLE
    ./Install-PowerLSS.ps1 -ForceCreate
#>

Param (
    [parameter(Mandatory=$false)][Switch]$ForceCreate
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


### MAIN SECTION ###

#Import PowerLSS helper module
#Import-Module "$($PSScriptRoot)\PowerLSS-Helper\PowerLSS-Helper.psm1"

$ErrorActionPreference = "stop"
Try
{
  #Variables
  $Global:HostName = $env:computername
  $Global:LogFile = "C:\Windows\Setup\Scripts\PowerLSS\Install-PowerLSS.log"
  Write-Log -Step "General" -Status "Information" -Comment "Start of processing"

  #PowerLSS scheduled task setup
  Write-Log -Step "Check" -Status "Information" -Comment "Check if PowerLSS scheduled task already exists"
  $command = "SCHTASKS /TN PowerLSS"
  $result = invoke-expression $command
  if ($result -match "ERROR")
  {
    Write-Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task doesn't exist yet"
    Write-Log -Step "Setup" -Status "Information" -Comment "Processing PowerLSS scheduled task setup"
    $command = "SCHTASKS /Create /XML C:\Windows\Setup\Scripts\PowerLSS\PowerLSS.xml /TN PowerLSS"
    $result = invoke-expression $command
    Write-Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task setup status - $Result"
  }
  else
  {
    $AlreadyExists = $true
    Write-Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task already exists"
    if ($ForceCreate.IsPresent)
    {
      Write-Log -Step "Setup" -Status "Information" -Comment "Trying to remove PowerLSS scheduled task"
      $command = "SCHTASKS /Delete /TN PowerLSS /F"
      $result = invoke-expression $command
      if ($result -match "SUCCESS")
      {
        Write-Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task removed successfully"
        Write-Log -Step "Setup" -Status "Information" -Comment "Processing PowerLSS scheduled task setup"
        $command = "SCHTASKS /Create /XML C:\Windows\Setup\Scripts\PowerLSS\PowerLSS.xml /TN PowerLSS"
        $result = invoke-expression $command
        Write-Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task setup status - $Result"
      }
      else
      {
        Write-Log -Step "Setup" -Status "Error" -Comment "PowerLSS scheduled task cannot be removed"
      }
    }
  }
  
  #Check status of PowerLSS scheduled task
  if (($result -match "SUCCESS") -or $AlreadyExists)
  {
    if ($AlreadyExists)
    {
      Write-Log -Step "Check" -Status "Information" -Comment "Checking PowerLSS scheduled task status"
      $Task = SCHTASKS /QUERY /TN PowerLSS /FO csv | ConvertFrom-Csv
      if ($Task.Status -eq 'Ready')
      {
        Write-Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task is ready to run"
        $DoStart = $true
      }
      else
      {
        if ($Task."Next Run Time" -eq 'Disabled')
        {
          Write-Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task is disabled, trying to enable it"
          $command = "SCHTASKS /CHANGE /ENABLE /TN PowerLSS"
          $result = invoke-expression $command
          if ($result -match "SUCCESS")
          {
            Write-Log -Step "Check" -Status "Information" -Comment "PowerLSS scheduled task was enabled successfully"
            $DoStart = $true
          }
          else
          {
            Write-Log -Step "Check" -Status "Error" -Comment "PowerLSS scheduled task cannot be enabled"
            $DoStart = $false
          }
        }
        else
        {
          Write-Log -Step "Check" -Status "Error" -Comment "PowerLSS scheduled task is already running"
          $DoStart = $false
        }
      }
    }
    else
    {
      Write-Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task installed successfully"
      $DoStart = $true
    }

    #Start PowerLSS scheduled task
    if ($DoStart)
    {
      Write-Log -Step "Startup" -Status "Information" -Comment "Processing PowerLSS scheduled task startup"
      $command = "SCHTASKS /Run /I /TN PowerLSS"
      $result = invoke-expression $command
      Write-Log -Step "Startup" -Status "Information" -Comment "PowerLSS scheduled task startup status - $Result"
      if ($result -match "SUCCESS")
      {
        Write-Log -Step "Startup" -Status "Information" -Comment "PowerLSS scheduled task started successfully"
      }
      else
      {
        Write-Log -Step "Startup" -Status "Error" -Comment "Problem during PowerLSS scheduled task startup"
      }
    }
  }
  else
  {
    Write-Log -Step "Setup" -Status "Error" -Comment "Problem during PowerLSS scheduled task setup"
  }

  Write-Log -Step "General" -Status "Information" -Comment "End of processing"
}
Catch
{
  $ErrorMessage = $_.Exception.Message
  $ErrorLine = $_.InvocationInfo.ScriptLineNumber
  Write-Log -Step "Error Management" -Status "Error" -Comment "Error on line $ErrorLine. The error message was: $ErrorMessage"
}


