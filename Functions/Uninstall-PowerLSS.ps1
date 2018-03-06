Function Uninstall-PowerLSS
{
  ### MAIN SECTION ###

  $ErrorActionPreference = "stop"
  Try
  {
    #Import PowerLSS module
    If (!(Get-module PowerLSS))
    {
      Import-Module PowerLSS
    }
    #Import PowerLSS helper functions
    $Path = Split-Path((Get-Module PowerLSS).path)
    ForEach ($Function in Get-ChildItem -Path "$Path\Helpers\*.ps1" -Recurse)
    {
      . $Function.FullName
    }

    #Variables
    $Script:LogFile = "$($PSScriptRoot)\Install-PowerLSS.log"

    Write-LSS_Log -Step "General" -Status "Information" -Comment "Start of processing"
    Write-LSS_Log -Step "Setup" -Status "Information" -Comment "Process with PowerLSS scheduled task removal"
    $Command = Remove-LSS_ScheduledTask
    if (($Command.Result -eq 'Success') -and ((Get-LSS_ScheduledTask).State -eq 'Not installed'))
    {
      Write-LSS_Log -Step "Setup" -Status "Information" -Comment "PowerLSS scheduled task removed successfully"
    }
    else
    {
      Write-LSS_Log -Step "Setup" -Status "Error" -Comment "PowerLSS scheduled task cannot be removed"
    }
    Write-LSS_Log -Step "General" -Status "Information" -Comment "End of processing"
  }
  Catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-LSS_Log -Step "Error Management" -Status "Error" -Comment "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}
