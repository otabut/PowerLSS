
Import-Module PowerLSS


Describe "Test Configure-PowerLSS" {

  Context "'SET'" {

    It "Set Configuration" {
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99
      (Get-LSS_Configuration -ConfigurationName Pester).InitialDelay | Should be 99
    }

    BeforeEach {
      Function global:Write-Host() {}
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Pester
      Remove-Item -Path Function:\Write-Host
    }
  }

  Context "'GET'" {

    It "Get 1 Configuration" {
      (Get-LSS_Configuration -ConfigurationName Pester).InitialDelay | Should be 99
    }

    BeforeEach {
      Function global:Write-Host() {}
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Pester
      Remove-Item -Path Function:\Write-Host
    }
  }

  Context "'COPY'" {

    It "Copy Configuration" {
      Copy-LSS_Configuration -Source Pester -Target Pester2
      (Get-LSS_Configuration -ConfigurationName Pester2).InitialDelay | Should be 99
      Remove-LSS_Configuration -ConfigurationName Pester2
    }

    BeforeEach {
      Function global:Write-Host() {}
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Pester
      Remove-Item -Path Function:\Write-Host
    }
  }

  Context "'REMOVE'" {

    It "Remove Configuration" {
      Remove-LSS_Configuration -ConfigurationName Pester
      (Get-LSS_Configuration -ConfigurationName Pester).InitialDelay | Should be $null
    }

    BeforeEach {
      Function global:Write-Host() {}
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99
    }

    AfterEach {
      Remove-Item -Path Function:\Write-Host
    }
  }
}


