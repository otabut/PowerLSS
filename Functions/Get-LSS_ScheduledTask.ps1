Function Get-LSS_ScheduledTask
{
  ### MAIN SECTION ###

  $ErrorActionPreference = "stop"
  Try
  {
    $States = @{"0"="Unknown";"1"="Disabled";"2"="Queued";"3"="Ready";"4"="Running"}
  
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
      $State = $States.Get_Item([string]($Task.State))
    }
    else
    {
      $State = "Not installed"
    }

    $Object = [PSCustomObject]@{TaskName="PowerLSS";State=$State}

    Return $Object
  }
  Catch
  {
    $ErrorMessage = $_.Exception.Message
    $ErrorLine = $_.InvocationInfo.ScriptLineNumber
    Write-Error "Error on line $ErrorLine. The error message was: $ErrorMessage"
  }
}
