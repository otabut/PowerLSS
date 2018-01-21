
# USAGE :
# Invoke-Pester .\Install-PowerLSS.tests.ps1 -CodeCoverage @{Path = 'C:\Windows\Setup\Scripts\PowerLSS\PowerLSS.ps1'; StartLine = 163; EndLine = 374}
# Covered 91,45 % of 117 analyzed commands in 1 file.


$Path = "C:\Windows\Setup\Scripts\PowerLSS"
$LogFile = "$Path\PowerLSS.log"


Describe "Test PowerLSS" {

<#
    [parameter(Mandatory=$false)][Switch]$AllowReboot,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Include,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$Exclude,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$ValidExitCodes,
    [parameter(Mandatory=$false)][ValidateNotNullOrEmpty()][String]$LogFile,
    [parameter(Mandatory=$false)][Switch]$ConsoleOutput,
    [parameter(Mandatory=$false)][Switch]$Output,
    [parameter(Mandatory=$false)][Switch]$CustomLogging,
    [parameter(Mandatory=$false)][Switch]$DontRunPreActions,
    [parameter(Mandatory=$false)][Switch]$DontRunPostActions
#>


  Context "General" {

    It "With -InitialDelay switch" {
      & "$Path\PowerLSS.ps1" -InitialDelay 1 -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Waiting for 1 seconds before performing any actions...").count | should be 1
    }

    It "With -DisableAtTheEnd switch" {
      & "$Path\PowerLSS.ps1" -DisableAtTheEnd -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Scheduled task has been disabled").count | should be 1
    }

    BeforeEach {
      Copy-item "C:\Windows\Setup\Scripts\PowerLSS\PostInstall\Examples\02-Run Notepad.ps1" "C:\Windows\Setup\Scripts\PowerLSS\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "C:\Windows\Setup\Scripts\PowerLSS\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "Script that triggers failure" {

    It "No switches" {
      & "$Path\PowerLSS.ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "has failed, no retry. Please check error message.").count | should be 1
    }

    It "With -Retry switch" {
      & "$Path\PowerLSS.ps1" -Retry -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "has failed once, trying one more time").count | should be 1
      ($Trace -match "has failed after 2 attempts. Please check error message.").count | should be 1
    }
    
    It "With -ContinueOnFailure switch" {
      & "$Path\PowerLSS.ps1" -ContinueOnFailure -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "has failed, no retry. Please check error message.").count | should be 1
      ($Trace -match "Continue on failure is active, moving on").count | should be 1
    }

    It "With -ContinueOnFailure and -Retry switches" {
      & "$Path\PowerLSS.ps1" -ContinueOnFailure -Retry -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "has failed once, trying one more time").count | should be 1
      ($Trace -match "has failed after 2 attempts. Please check error message.").count | should be 1
      ($Trace -match "Continue on failure is active, moving on").count | should be 1
    }

    BeforeEach {
      Copy-item "C:\Windows\Setup\Scripts\PowerLSS\PostInstall\Examples\01-Trigger Failure.ps1" "C:\Windows\Setup\Scripts\PowerLSS\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "C:\Windows\Setup\Scripts\PowerLSS\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "Script that triggers restart" {

    It "No switches" {
      & "$Path\PowerLSS.ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Computer reboot has been requested but reboot not currently allowed").count | should be 1
      ($Trace -match "Not allowed to continue because of reboot request. Stopping.").count | should be 1
    }

    It "With -ContinueIfRebootRequest switch" {
      & "$Path\PowerLSS.ps1" -ContinueIfRebootRequest -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Computer reboot has been requested but reboot not currently allowed").count | should be 1
      ($Trace -match "Allowed to continue despite reboot request").count | should be 1
    }

    BeforeEach {
      Copy-item "C:\Windows\Setup\Scripts\PowerLSS\PostInstall\Examples\03-Restart.ps1" "C:\Windows\Setup\Scripts\PowerLSS\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "C:\Windows\Setup\Scripts\PowerLSS\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "Script with unsupported extension" {

    It "No switches" {
      & "$Path\PowerLSS.ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Return Message : Ignored - file extension not supported").count | should be 1
    }

    BeforeEach {
      Copy-item "C:\Windows\Setup\Scripts\PowerLSS\PostInstall\Examples\04-Unsupported extension.xyz" "C:\Windows\Setup\Scripts\PowerLSS\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "C:\Windows\Setup\Scripts\PowerLSS\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "Script that return wrong status" {

    It "No switches" {
      & "$Path\PowerLSS.ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "provide unsupported return status : ").count | should be 1
    }

    BeforeEach {
      Copy-item "C:\Windows\Setup\Scripts\PowerLSS\PostInstall\Examples\05-Return wrong status.ps1" "C:\Windows\Setup\Scripts\PowerLSS\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "C:\Windows\Setup\Scripts\PowerLSS\PostInstall" -File | Remove-Item -Force
    }
  }
}
