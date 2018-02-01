Function Set-LSS_CurrentConfiguration
{
  Param (
    [parameter(Mandatory=$false)][String]$ConfigurationName,
    [parameter(Mandatory=$false)][Switch]$Quiet
  )
  
  $ErrorActionPreference = "stop"
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
      if ($Quiet.IsPresent)
      {
        Return [PSCustomObject]@{ConfigurationName=$ConfigurationName;Action="SetDefault";Result="Success"}
      }
      else
      {
        Write-Host "Current configuration updated successfully" -ForegroundColor Green
      }
    }
    else
    {
      if ($Quiet.IsPresent)
      {
        Return [PSCustomObject]@{ConfigurationName=$ConfigurationName;Action="SetDefault";Result="Not found"}
      }
      else
      {
        Write-Host "Configuration $ConfigurationName cannot be found" -ForegroundColor Yellow
      }
    }
  }
  catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-Error "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}
