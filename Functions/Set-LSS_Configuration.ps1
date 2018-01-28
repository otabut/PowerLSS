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

  $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"
  $RegPath = "$RegBasePath\$ConfigurationName"

  if (!(Test-Path $RegBasePath -PathType Container))
  {
    New-Item -Path $RegBasePath | Out-Null
  }

  if (!(Test-Path $RegPath -PathType Container))
  {
    New-Item -Path $RegPath | Out-Null
  }
  
  if ((((Get-ChildItem -Path $RegBasePath).PSChildName).count -eq 0) -or ((Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration" -eq $null))
  {
    New-ItemProperty -Path $RegBasePath -Name "CurrentConfiguration" -Value $ConfigurationName -PropertyType String -Force | Out-Null
    Write-Host "Since there is no current configuration, $ConfigurationName has been set as default configuration" -ForegroundColor Yellow
  }

  New-ItemProperty -Path $RegPath -Name $Parameter -Value $Value -PropertyType string -Force | Out-Null
  Write-Host "Parameter set successfully" -ForegroundColor Green
}
