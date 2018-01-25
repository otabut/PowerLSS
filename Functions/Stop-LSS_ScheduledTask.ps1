Function Stop-LSS_ScheduledTask
{
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
      if  ($Task.State -eq 4)
      {
        $Task.Stop(0) | Out-Null
        $Result = "Success"
      }
      else
      {
        $Result = "Not running"
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
