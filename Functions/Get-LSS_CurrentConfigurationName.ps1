Function Get-LSS_CurrentConfigurationName
{
  Param (
    [parameter(Mandatory=$false)][Switch]$Quiet
  )
  
  $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"
  $CurrentConfiguration = (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration"
  if (!($CurrentConfiguration))
  {
    if (!($Quiet.IsPresent)) { Write-Host "No current configuration has been set" -ForegroundColor Red }
  }
  else
  {
    $CurrentConfiguration
  }
}
