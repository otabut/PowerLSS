Import-Module PowerLSS
$Path = Split-Path((Get-Module PowerLSS).path)
$LogFile = "$Path\Functions\Install-PowerLSS.log"

Describe "Test Install-PowerLSS" {

  Context "'PowerLSS Scheduled Task is present/enabled'" {

    It "No switches" {
      Install-PowerLSS -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }
    
    It "Only Force switch" {
      Install-PowerLSS -Force -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "Only NoStart switch" {
      Install-PowerLSS -NoStart -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    It "Force and NoStart switches" {
      Install-PowerLSS -Force -NoStart -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }
    
    BeforeEach {
      Install-PowerLSS -NoStart -LogFile "$LogFile"
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Remove-LSS_ScheduledTask
    }
  }
  
  Context "'PowerLSS Scheduled Task is present/disabled'" {

    It "No switches" {
      Install-PowerLSS -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "Only Force switch" {
      Install-PowerLSS -Force -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "Only NoStart switch" {
      Install-PowerLSS -NoStart -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    It "Force and NoStart switches" {
      Install-PowerLSS -Force -NoStart -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    BeforeEach {
      Install-PowerLSS -NoStart -LogFile "$LogFile"
      Disable-LSS_ScheduledTask
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Remove-LSS_ScheduledTask
    }
  }

  Context "'PowerLSS Scheduled Task is absent'" {

    It "No switches" {
      Install-PowerLSS -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "Only Force switch" {
      Install-PowerLSS -Force -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "Only NoStart switch" {
      Install-PowerLSS -NoStart -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    It "Force and NoStart switches" {
      Install-PowerLSS -Force -NoStart -LogFile "$LogFile"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "NoStart switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    BeforeEach {
      Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
    }

    AfterEach {
      Remove-LSS_ScheduledTask
    }
  }
}

Remove-Item $LogFile -Force -ErrorAction SilentlyContinue
