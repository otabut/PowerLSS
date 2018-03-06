
Import-Module PowerLSS


Describe "Test Configure-PowerLSS" {

  Context "'SET'" {

    It "Set Configuration" {
      (Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99 -Quiet).Result | Should be "Success"
      (Get-LSS_Configuration -ConfigurationName Pester -Quiet).InitialDelay | Should be 99
    }

    BeforeEach {
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Pester -Quiet
    }
  }

  Context "'GET'" {

    It "Get 1 Configuration" {
      (Get-LSS_Configuration -ConfigurationName Pester -Quiet).InitialDelay | Should be 99
    }

    BeforeEach {
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99 -Quiet
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Pester -Quiet
    }
  }

  Context "'COPY'" {

    It "Copy Configuration" {
      (Copy-LSS_Configuration -Source Pester -Target Pester2 -Quiet).Result | Should be "Success"
      (Get-LSS_Configuration -ConfigurationName Pester2 -Quiet).InitialDelay | Should be 99
    }

    BeforeEach {
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99 -Quiet
    }

    AfterEach {
      Remove-LSS_Configuration -ConfigurationName Pester -Quiet
      Remove-LSS_Configuration -ConfigurationName Pester2 -Quiet
    }
  }

  Context "'REMOVE'" {

    It "Remove Configuration" {
      (Remove-LSS_Configuration -ConfigurationName Pester -Quiet).Result | Should be "Success"
      (Get-LSS_Configuration -ConfigurationName Pester -Quiet).InitialDelay | Should be $null
    }

    BeforeEach {
      Set-LSS_Configuration -ConfigurationName Pester -Parameter InitialDelay -Value 99 -Quiet
    }

    AfterEach {
    }
  }
}
