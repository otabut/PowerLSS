Function Copy-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Source,
    [parameter(Mandatory=$true)][ValidateNotNullOrEmpty()][String]$Target,
    [parameter(Mandatory=$false)][Switch]$Quiet
  )
  
  $ErrorActionPreference = "stop"
  try
  {
    If (!(Get-module PowerLSS))
    {
      Import-Module PowerLSS
    }

    $ParameterList = @("LogFile","InitialDelay","Include","Exclude","Retry","AllowReboot","ContinueIfRebootRequest","ContinueOnFailure","DisableAtTheEnd","ConsoleOutput","Output","CustomLogging","DontRunPreActions","DontRunPostActions","ScriptsFolder","ScheduledTaskLogFile")
    $RegPathSource = "HKLM:\SOFTWARE\PowerLSS\$Source"
    $RegPathTarget = "HKLM:\SOFTWARE\PowerLSS\$Target"

    if (!(Test-Path $RegPathSource -PathType Container))
    {
      if ($Quiet.IsPresent)
      {
        Return [PSCustomObject]@{ConfigurationName=$Source;Action="Copy";Result="Not found"}
      }
      else
      {
        Write-Host "Source configuration doesn't exist" -ForegroundColor Red
        Return
      }
    }

    if (!(Test-Path $RegPathTarget -PathType Container))
    {
      New-Item -Path $RegPathTarget | Out-Null
    }
  
    ForEach ($Parameter in $ParameterList)
    {
      $Value = (Get-ItemProperty -Path $RegPathSource)."$Parameter"
      if ($Value)
      {
        New-ItemProperty -Path $RegPathTarget -Name $Parameter -Value $Value -PropertyType string -Force | Out-Null
      }
    }

    if ($Quiet.IsPresent)
    {
      Return [PSCustomObject]@{ConfigurationName=$Target;Action="Copy";Result="Success"}
    }
    else
    {
      Write-Host "Configuration copied successfully" -ForegroundColor Green
    }
  }
  catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-Error "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}
