Function Set-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true)][String]$ConfigurationName,
    [parameter(Mandatory=$true)][ValidateSet("LogFile","InitialDelay","Include","Exclude","ValidExitCodes","Retry","AllowReboot","ContinueIfRebootRequest","ContinueOnFailure","DisableAtTheEnd","ConsoleOutput","Output","CustomLogging","DontRunPreActions","DontRunPostActions","ScriptsFolder","ScheduledTaskLogFile")][String]$Parameter,
    [parameter(Mandatory=$true)][String]$Value
  )
  
  If (!(Get-module PowerLSS))
  {
    Import-Module PowerLSS
  }

  $RegPath = "HKLM:\SOFTWARE\PowerLSS\$ConfigurationName"
  if (!(Test-Path $RegPath -PathType Container))
  {
    New-Item -Path $RegPath | Out-Null
  }
  
  New-ItemProperty -Path $RegPath -Name $Parameter -Value $Value -PropertyType string -Force | Out-Null
  Write-Host "Parameter set successfully" -ForegroundColor Green
}
