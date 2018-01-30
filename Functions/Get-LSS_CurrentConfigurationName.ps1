Function Get-LSS_CurrentConfigurationName
{
  $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"
  $CurrentConfiguration = (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration"
  if (!($CurrentConfiguration))
  {
    Write-Host "No current configuration has been set" -ForegroundColor Red
  }
  else
  {
    $CurrentConfiguration
  }
}
