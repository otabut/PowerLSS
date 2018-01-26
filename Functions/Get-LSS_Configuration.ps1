Function Get-LSS_Configuration
{
  Param (
    [parameter(Mandatory=$true,ParameterSetName='Specific')][ValidateNotNullOrEmpty()][String]$ConfigurationName,
    [parameter(Mandatory=$true,ParameterSetName='Current')][Switch]$Current,
    [parameter(Mandatory=$true,ParameterSetName='All')][Switch]$All
  )
  
  If (!(Get-module PowerLSS))
  {
    Import-Module PowerLSS
  }

  #Variables
  $Path = Split-Path((Get-Module PowerLSS).path)
  $RegBasePath = "HKLM:\SOFTWARE\PowerLSS"
  $ParameterList = @("LogFile","InitialDelay","Include","Exclude","ValidExitCodes","Retry","AllowReboot","ContinueIfRebootRequest","ContinueOnFailure","DisableAtTheEnd","ConsoleOutput","Output","CustomLogging","DontRunPreActions","DontRunPostActions","ScriptsFolder","ScheduledTaskLogFile")

  switch ($PsCmdlet.ParameterSetName)
  { 
    “Specific”
    {
      $AllConfigurations = $ConfigurationName.split(',')
    }
    “Current”
    {
      $AllConfigurations = (Get-ItemProperty -Path $RegBasePath)."CurrentConfiguration"
      if (!($AllConfigurations))
      {
        Write-Host "No current configuration has been set. Return default values" -ForegroundColor Red

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
    }
    "All"
    {
      $AllConfigurations = (Get-ChildItem -Path $RegBasePath).PSChildName
    }
  } 
    
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
    if (Test-Path $RegPath -PathType Container)
    {
      Write-Host "Configuration $ConfigurationName was found" -ForegroundColor Green
      ForEach ($Parameter in $ParameterList)
      {
        $Value = (Get-ItemProperty -Path $RegPath)."$Parameter"
        if ($Value)
        {
          Set-Variable $Parameter -Value $Value
          #Write-Host "Value $Value found for $Parameter"
        }
        else
        {
          Write-Host "No value found for $Parameter, using default value" -ForegroundColor Yellow
        }
      }
    }
    else
    {
      Write-Host "Configuration $ConfigurationName is missing, using default values" -ForegroundColor Yellow
    }
  
    [PSCustomObject]@{
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
