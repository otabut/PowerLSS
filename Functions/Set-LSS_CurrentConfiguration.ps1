Function Set-LSS_CurrentConfiguration
{
  Param (
    [parameter(Mandatory=$false)][String]$ConfigurationName
  )
  
  try
  {
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
  catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-Error -Step "Error Management" -Status "Error" -Comment "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}
