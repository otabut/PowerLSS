Function Get-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true,ParameterSetName='Specific')][ValidateNotNullOrEmpty()][String]$ConfigurationName,
    [parameter(Mandatory=$true,ParameterSetName='Current')][Switch]$Current,
    [parameter(Mandatory=$true,ParameterSetName='All')][Switch]$All,
    [parameter(Mandatory=$true)][Switch]$Quiet
  )

  ## FUNCTIONS

  Function Read-Config ($AllConfigurations)
  {
    ForEach ($ConfigurationName in $AllConfigurations)
    {
      #Define default values
      $LogFile = "$Path\PowerLSS.log"
      $InitialDelay = 60
      $Include = "ps1"
      $Exclude = ""
      $ValidExitCodes = "0,3010"
      $Retry = "False"
      $AllowReboot = "False"
      $ContinueIfRebootRequest = "False"
      $ContinueOnFailure = "False"
      $DisableAtTheEnd = "True"
      $ConsoleOutput = "False"
      $Output = "False"
      $CustomLogging = "True"
      $DontRunPreActions = "False"
      $DontRunPostActions = "False"
      $ScriptsFolder = "PostInstall"
      $ScheduledTaskLogFile = "$Path\Functions\Install-PowerLSS.log"
    
      $RegPath = $RegBasePath + "\$ConfigurationName"
      $CurrentConfiguration = ($ConfigurationName -eq (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration")
      if (Test-Path $RegPath -PathType Container)
      {
        if (!($Quiet.IsPresent)) { Write-Host "Configuration $ConfigurationName was found" -ForegroundColor Green }
        ForEach ($Parameter in $ParameterList)
        {
          $Value = (Get-ItemProperty -Path $RegPath)."$Parameter"
          if ($Value)
          {
            Set-Variable $Parameter -Value $Value
          }
          else
          {
            if (!($Quiet.IsPresent)) { Write-Host "No value found for $Parameter, using default value" -ForegroundColor Yellow }
          }
        }
        $ReturnObject = $True
      }
      else
      {
        if ($CurrentConfiguration)
        {
          if (!($Quiet.IsPresent)) { Write-Host "Configuration $ConfigurationName cannot be found but this is the current configuration so returning default values" -ForegroundColor Yellow }
          $ReturnObject = $True
        }
        else
        {
          if (!($Quiet.IsPresent)) { Write-Host "Configuration $ConfigurationName cannot be found" -ForegroundColor Yellow }
          $ReturnObject = $False
        }
      }
  
      if ($ReturnObject)
      {
        [PSCustomObject]@{
          "ConfigurationName" = $ConfigurationName
          "LogFile" = $LogFile
          "InitialDelay" = [int]$InitialDelay
          "Include" = $Include
          "Exclude" = $Exclude
          "ValidExitCodes" = $ValidExitCodes
          "Retry" = ($Retry -eq "True")
          "AllowReboot" = ($AllowReboot -eq "True")
          "ContinueIfRebootRequest" = ($ContinueIfRebootRequest -eq "True")
          "ContinueOnFailure" = ($ContinueOnFailure -eq "True")
          "DisableAtTheEnd" = ($DisableAtTheEnd -eq "True")
          "ConsoleOutput" = ($ConsoleOutput -eq "True")
          "Output" = ($Output -eq "True")
          "CustomLogging" = ($CustomLogging -eq "True")
          "DontRunPreActions" = ($DontRunPreActions -eq "True")
          "DontRunPostActions" = ($DontRunPostActions -eq "True")
          "ScriptsFolder" = $ScriptsFolder
          "ScheduledTaskLogFile" = $ScheduledTaskLogFile
        }
      }
    }
  }

  ## MAIN
  
  $ErrorActionPreference = "stop"
  try
  {
    If (!(Get-module PowerLSS))
    {
      Import-Module PowerLSS
    }

    #Variables
    $Path = Split-Path((Get-Module PowerLSS).path)
    $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"
    $ParameterList = @("LogFile","InitialDelay","Include","Exclude","ValidExitCodes","Retry","AllowReboot","ContinueIfRebootRequest","ContinueOnFailure","DisableAtTheEnd","ConsoleOutput","Output","CustomLogging","DontRunPreActions","DontRunPostActions","ScriptsFolder","ScheduledTaskLogFile")

    if (!(Test-Path $RegBasePath -PathType Container))
    {
      New-Item -Path $RegBasePath | Out-Null
    }

    switch ($PsCmdlet.ParameterSetName)
    { 
      "Specific"
      {
        Read-Config $ConfigurationName.split(',')
      }
      "Current"
      {
        $CurrentConfiguration = (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration"
        if (!($CurrentConfiguration))
        {
          if (!($Quiet.IsPresent)) { Write-Host "No current configuration has been set, returning default values" -ForegroundColor Red }
  
          #Define default values
          $LogFile = "$Path\PowerLSS.log"
          $InitialDelay = 60
          $Include = "ps1"
          $Exclude = ""
          $ValidExitCodes = "0,3010"
          $Retry = "False"
          $AllowReboot = "False"
          $ContinueIfRebootRequest = "False"
          $ContinueOnFailure = "False"
          $DisableAtTheEnd = "True"
          $ConsoleOutput = "False"
          $Output = "False"
          $CustomLogging = "True"
          $DontRunPreActions = "False"
          $DontRunPostActions = "False"
          $ScriptsFolder = "PostInstall"
          $ScheduledTaskLogFile = "$Path\Functions\Install-PowerLSS.log"

          [PSCustomObject]@{
            "LogFile" = $LogFile
            "InitialDelay" = [int]$InitialDelay
            "Include" = $Include
            "Exclude" = $Exclude
            "ValidExitCodes" = $ValidExitCodes
            "Retry" = ($Retry -eq "True")
            "AllowReboot" = ($AllowReboot -eq "True")
            "ContinueIfRebootRequest" = ($ContinueIfRebootRequest -eq "True")
            "ContinueOnFailure" = ($ContinueOnFailure -eq "True")
            "DisableAtTheEnd" = ($DisableAtTheEnd -eq "True")
            "ConsoleOutput" = ($ConsoleOutput -eq "True")
            "Output" = ($Output -eq "True")
            "CustomLogging" = ($CustomLogging -eq "True")
            "DontRunPreActions" = ($DontRunPreActions -eq "True")
            "DontRunPostActions" = ($DontRunPostActions -eq "True")
            "ScriptsFolder" = $ScriptsFolder
            "ScheduledTaskLogFile" = $ScheduledTaskLogFile
          }
        }
        else
        {
          Read-Config $CurrentConfiguration
        }
      }
      "All"
      {
        $AllConfigurations = (Get-ChildItem -Path $RegBasePath).PSChildName
        if (!($AllConfigurations))
        {
          if (!($Quiet.IsPresent)) { Write-Host "No configuration found" -ForegroundColor Yellow }
        }
        else
        {
          Read-Config $AllConfigurations
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
