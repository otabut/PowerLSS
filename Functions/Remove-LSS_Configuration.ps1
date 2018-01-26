Function Remove-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true)][String]$ConfigurationName
  )
  
  If (!(Get-module PowerLSS))
  {
    Import-Module PowerLSS
  }

  $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"
  $AllConfigurations = $ConfigurationName.split(',')

  ForEach ($ConfigurationName in $AllConfigurations)
  {
    $RegPath = "$RegBasePath\$ConfigurationName"
    if (Test-Path $RegPath -PathType Container)
    {
      if ($ConfigurationName -ne (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration")
      {
        Remove-Item -Path $RegPath -Force
        Write-Host "Configuration $ConfigurationName has been removed successfully" -ForegroundColor Green
      }
      else
      {
        Write-Host "Configuration $ConfigurationName cannot be removed as it is the current configuration" -ForegroundColor Red
      }
    }
    else
    {
      Write-Host "Configuration $ConfigurationName cannot be found" -ForegroundColor Yellow
    }
  }
}
