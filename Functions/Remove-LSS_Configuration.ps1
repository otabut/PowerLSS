Function Remove-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true)][String]$ConfigurationName,
    [parameter(Mandatory=$false)][Switch]$Quiet
  )
  
  $ErrorActionPreference = "stop"
  try
  {
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
          if ($Quiet.IsPresent)
          {
            Return [PSCustomObject]@{ConfigurationName=$ConfigurationName;Action="Remove";Result="Success"}
          }
          else
          {
            Write-Host "Configuration $ConfigurationName has been removed successfully" -ForegroundColor Green
          }
        }
        else
        {
          if ($Quiet.IsPresent)
          {
            $Object = [PSCustomObject]@{ConfigurationName=$ConfigurationName;Action="Remove";Result="Error"}
            Return $Object
          }
          else
          {
            Write-Host "Configuration $ConfigurationName cannot be removed as it is the current configuration" -ForegroundColor Red
          }
        }
      }
      else
      {
        if ($Quiet.IsPresent)
        {
          $Object = [PSCustomObject]@{ConfigurationName=$ConfigurationName;Action="Remove";Result="Not found"}
          Return $Object
        }
        else
        {
          Write-Host "Configuration $ConfigurationName cannot be found" -ForegroundColor Yellow
        }
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
