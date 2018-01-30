
Import-Module PowerLSS
$Path = Split-Path((Get-Module PowerLSS).path)
$LogFile = "$Path\PowerLSS.log"

Describe "Test PowerLSS" {

  Context "'General'" {

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

    It "With -Include switch" {
      & "$Path\PowerLSS.ps1" -Include "ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Return Message : Ignored - file extension not supported").count | should be 0
    }

    It "With -Exclude switch" {
      & "$Path\PowerLSS.ps1" -Exclude "ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Return Message : Ignored - file extension not supported").count | should be 1
    }

    BeforeEach {
      Copy-item "$Path\PostInstall\Examples\02-Run Notepad.ps1" "$Path\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "$Path\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "'Script that triggers failure'" {

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
      Copy-item "$Path\PostInstall\Examples\01-Trigger Failure.ps1" "$Path\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "$Path\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "'Script that triggers restart'" {

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

    It "With -AllowReboot switch (and prevent restart loop feature)" {
      & "$Path\PowerLSS.ps1" -AllowReboot -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Computer reboot has been requested but this is first startup script so reboot is skipped").count | should be 1
    }

    BeforeEach {
      Copy-item "$Path\PostInstall\Examples\03-Restart.ps1" "$Path\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "$Path\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "'Script with unsupported extension'" {

    It "No switches" {
      & "$Path\PowerLSS.ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "Return Message : Ignored - file extension not supported").count | should be 1
    }

    BeforeEach {
      Copy-item "$Path\PostInstall\Examples\04-Unsupported extension.xyz" "$Path\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "$Path\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "'Script that return wrong status'" {

    It "No switches" {
      & "$Path\PowerLSS.ps1" -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "provide unsupported return status : ").count | should be 1
    }

    BeforeEach {
      Copy-item "$Path\PostInstall\Examples\05-Return wrong status.ps1" "$Path\PostInstall"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Get-ChildItem -Path "$Path\PostInstall" -File | Remove-Item -Force
    }
  }

  Context "'Configurations'" {

    It "With -ConfigurationName switch" {
      & "$Path\PowerLSS.ps1" -ConfigurationName Test
      $Trace = Get-Content $LogFile
      ($Trace -match "Waiting for 1 seconds before performing any actions...").count | should be 1
    }

    It "With -CurrentConfiguration switch" {
      Set-LSS_CurrentConfiguration -ConfigurationName Test
      & "$Path\PowerLSS.ps1" -CurrentConfiguration
      $Trace = Get-Content $LogFile
      ($Trace -match "Waiting for 1 seconds before performing any actions...").count | should be 1
    }

    BeforeEach {
      Function global:Write-Host() {}
      Set-LSS_Configuration -ConfigurationName Test -Parameter InitialDelay -Value 1 | Out-Null
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Test | Out-Null
      Remove-Item -Path Function:\Write-Host
      Get-ChildItem -Path "$Path\PostInstall" -File | Remove-Item -Force
    }
  }
}

Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
