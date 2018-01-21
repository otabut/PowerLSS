
$Path = "C:\Windows\Setup\Scripts\PowerLSS"
$LogFile = "$Path\Install-PowerLSS.log"


Describe "Test Install-PowerLSS" {

  Context "'PowerLSS Scheduled Task is present/enabled'" {

    It "no switches" {
      & "$Path\Install-PowerLSS.ps1"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }
    
    It "only ForceCreate switch" {
      & "$Path\Install-PowerLSS.ps1" -ForceCreate
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "only WithoutStarting switch" {
      & "$Path\Install-PowerLSS.ps1" -WithoutStarting
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    It "ForceCreate and WithoutStarting switches" {
      & "$Path\Install-PowerLSS.ps1" -ForceCreate -WithoutStarting
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }
    
    BeforeEach {
      & "$Path\Install-PowerLSS.ps1" -WithoutStarting
      Remove-Item $LogFile -Force
    }

    AfterEach {
      invoke-expression "SCHTASKS /DELETE /TN PowerLSS /F"
    }
  }
  
  Context "'PowerLSS Scheduled Task is present/disabled'" {

    It "no switches" {
      & "$Path\Install-PowerLSS.ps1"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "only ForceCreate switch" {
      & "$Path\Install-PowerLSS.ps1" -ForceCreate
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "only WithoutStarting switch" {
      & "$Path\Install-PowerLSS.ps1" -WithoutStarting
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    It "ForceCreate and WithoutStarting switches" {
      & "$Path\Install-PowerLSS.ps1" -ForceCreate -WithoutStarting
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 2
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 1
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 1
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    BeforeEach {
      & "$Path\Install-PowerLSS.ps1" -WithoutStarting
      invoke-expression "SCHTASKS /CHANGE /DISABLE /TN PowerLSS"
      Remove-Item $LogFile -Force
    }

    AfterEach {
      invoke-expression "SCHTASKS /DELETE /TN PowerLSS /F"
    }
  }

  Context "'PowerLSS Scheduled Task is absent'" {

    It "no switches" {
      & "$Path\Install-PowerLSS.ps1"
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "only ForceCreate switch" {
      & "$Path\Install-PowerLSS.ps1" -ForceCreate
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 0
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 1
    }

    It "only WithoutStarting switch" {
      & "$Path\Install-PowerLSS.ps1" -WithoutStarting
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    It "ForceCreate and WithoutStarting switches" {
      & "$Path\Install-PowerLSS.ps1" -ForceCreate -WithoutStarting
      $Trace = Get-Content $LogFile
      ($Trace -match "PowerLSS scheduled task already exists").count | should be 1
      ($Trace -match "Trying to remove PowerLSS scheduled task").count | should be 0
      ($Trace -match "PowerLSS scheduled task installed successfully").count | should be 1
      ($Trace -match "PowerLSS scheduled task was enabled successfully").count | should be 0
      ($Trace -match "PowerLSS scheduled task is ready to run").count | should be 0
      ($Trace -match "WithoutStarting switch is present, so skipping startup").count | should be 1
      ($Trace -match "PowerLSS scheduled task started successfully").count | should be 0
    }

    BeforeEach {
      #invoke-expression "SCHTASKS /DELETE /TN PowerLSS /F"
      Remove-Item $LogFile -Force
    }

    AfterEach {
      invoke-expression "SCHTASKS /DELETE /TN PowerLSS /F"
    }
  }
}
