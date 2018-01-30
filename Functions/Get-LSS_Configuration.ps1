Function Get-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true,ParameterSetName='Specific')][ValidateNotNullOrEmpty()][String]$ConfigurationName,
    [parameter(Mandatory=$true,ParameterSetName='Current')][Switch]$Current,
    [parameter(Mandatory=$true,ParameterSetName='All')][Switch]$All
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
      $Retry = $false
      $AllowReboot = $false
      $ContinueIfRebootRequest = $false
      $ContinueOnFailure = $false
      $DisableAtTheEnd = $true
      $ConsoleOutput = $false
      $Output = $false
      $CustomLogging = $true
      $DontRunPreActions = $false
      $DontRunPostActions = $false
      $ScriptsFolder = "PostInstall"
      $ScheduledTaskLogFile = "$Path\Functions\Install-PowerLSS.log"
    
      $RegPath = $RegBasePath + "\$ConfigurationName"
      $CurrentConfiguration = ($ConfigurationName -eq (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration")
      if (Test-Path $RegPath -PathType Container)
      {
        Write-Host "Configuration $ConfigurationName was found" -ForegroundColor Green
        ForEach ($Parameter in $ParameterList)
        {
          $Value = (Get-ItemProperty -Path $RegPath)."$Parameter"
          if ($Value)
          {
            Set-Variable $Parameter -Value $Value
          }
          else
          {
            Write-Host "No value found for $Parameter, using default value" -ForegroundColor Yellow
          }
        }
        $ReturnObject = $True
      }
      else
      {
        if ($CurrentConfiguration)
        {
          Write-Host "Configuration $ConfigurationName cannot be found but this is the current configuration so returning default values" -ForegroundColor Yellow
          $ReturnObject = $True
        }
        else
        {
          Write-Host "Configuration $ConfigurationName cannot be found" -ForegroundColor Yellow
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
          "Retry" = @{$true="True";$false="False"}[$Retry -eq "True"]
          "AllowReboot" = @{$true="True";$false="False"}[$AllowReboot -eq "True"]
          "ContinueIfRebootRequest" = @{$true="True";$false="False"}[$ContinueIfRebootRequest -eq "True"]
          "ContinueOnFailure" = @{$true="True";$false="False"}[$ContinueOnFailure -eq "True"]
          "DisableAtTheEnd" = @{$true="True";$false="False"}[$DisableAtTheEnd -eq "True"]
          "ConsoleOutput" = @{$true="True";$false="False"}[$ConsoleOutput -eq "True"]
          "Output" = @{$true="True";$false="False"}[$Output -eq "True"]
          "CustomLogging" = @{$true="True";$false="False"}[$CustomLogging -eq "True"]
          "DontRunPreActions" = @{$true="True";$false="False"}[$DontRunPreActions -eq "True"]
          "DontRunPostActions" = @{$true="True";$false="False"}[$DontRunPostActions -eq "True"]
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
          Write-Host "No current configuration has been set, returning default values" -ForegroundColor Red
  
          #Define default values
          $LogFile = "$Path\PowerLSS.log"
          $InitialDelay = 60
          $Include = "ps1"
          $Exclude = ""
          $ValidExitCodes = "0,3010"
          $Retry = $false
          $AllowReboot = $false
          $ContinueIfRebootRequest = $false
          $ContinueOnFailure = $false
          $DisableAtTheEnd = $true
          $ConsoleOutput = $false
          $Output = $false
          $CustomLogging = $true
          $DontRunPreActions = $false
          $DontRunPostActions = $false
          $ScriptsFolder = "PostInstall"
          $ScheduledTaskLogFile = "$Path\Functions\Install-PowerLSS.log"

          [PSCustomObject]@{
            "LogFile" = $LogFile
            "InitialDelay" = $InitialDelay
            "Include" = $Include
            "Exclude" = $Exclude
            "ValidExitCodes" = $ValidExitCodes
            "Retry" = $Retry
            "AllowReboot" = $AllowReboot
            "ContinueIfRebootRequest" = $ContinueIfRebootRequest
            "ContinueOnFailure" = $ContinueOnFailure
            "DisableAtTheEnd" = $DisableAtTheEnd
            "ConsoleOutput" = $ConsoleOutput
            "Output" = $Output
            "CustomLogging" = $CustomLogging
            "DontRunPreActions" = $DontRunPreActions
            "DontRunPostActions" = $DontRunPostActions
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
          Write-Host "No configuration found" -ForegroundColor Yellow
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
