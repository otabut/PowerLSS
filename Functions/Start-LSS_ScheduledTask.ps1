Function Start-LSS_ScheduledTask
{
  Param (
    [parameter(Mandatory=$false)][Switch]$Force,
    [parameter(Mandatory=$false)][Switch]$Quiet
  )
  ### MAIN SECTION ###

  $ErrorActionPreference = "stop"
  Try
  {
    $TaskScheduler = New-Object -ComObject Schedule.Service
    $TaskScheduler.Connect("localhost")
    $TaskFolder = $TaskScheduler.GetFolder('\')
    $ErrorActionPreference = "SilentlyContinue"
    try
    {
      $Task = $TaskFolder.GetTask("PowerLSS")
    }
    catch
    {
    }
    $ErrorActionPreference = "stop"
  
    if ($Task)
    {
      $States = @{"0"="Unknown";"1"="Disabled";"2"="Queued";"3"="Ready";"4"="Running"}
      $State = $States.Get_Item([string]($Task.State))
      If ($State -eq 'Disabled')
      {
        if (!($Quiet.IsPresent)) { Write-Host "Scheduled task is disabled" -ForegroundColor Yellow }
        If ($Force.IsPresent)
        {
          $void = Enable-LSS_ScheduledTask
          $Task = $TaskFolder.GetTask("PowerLSS")
          $State = $States.Get_Item([string]($Task.State))
        }
      }
      If ($State -eq 'Ready')
      {
        $Task.Run($null) | Out-Null
        $Result = "Success"
      }
      else
      {
        if (!($Quiet.IsPresent)) { Write-Host "Unable to start scheduled task" -ForegroundColor Red }
        $Result = "Error"
      }
    }
    else
    {
      $Result = "Not installed"
    }

    $Object = [PSCustomObject]@{TaskName="PowerLSS";Result=$Result}

    Return $Object
  }
  Catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-Error "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}
