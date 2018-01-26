Function Set-LSS_CurrentConfiguration
{
  Param (
    [parameter(Mandatory=$false)][String]$ConfigurationName
  )
  
  If (!(Get-module PowerLSS))
  {
    Import-Module PowerLSS
  }

  #Variables
  $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"

  if (Test-Path "$RegBasePath\$ConfigurationName" -PathType Container)
  {
    New-ItemProperty -Path $RegBasePath -Name "CurrentConfiguration" -Value $ConfigurationName -PropertyType String -Force | Out-Null
    Write-Host "Current configuration updated successfully" -ForegroundColor Green
  }
  else
  {
    Write-Host "Configuration $ConfigurationName cannot be found" -ForegroundColor Yellow
  }
}
