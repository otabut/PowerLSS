Function Register-LSS_ScheduledTask
{
  ### MAIN SECTION ###

  $ErrorActionPreference = "stop"
  Try
  {
    Import-Module PowerLSS
    $Path = Split-Path((Get-Module PowerLSS).path)

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
      $Result = "Already exists"
    }
    else
    {
      $TASK_CREATION = @{"TASK_VALIDATE_ONLY"="0x1";"TASK_CREATE"="0x2";"TASK_UPDATE"="0x4";"TASK_CREATE_OR_UPDATE"="0x6";"TASK_DISABLE"="0x8";"TASK_DONT_ADD_PRINCIPAL_ACE"="0x10";"TASK_IGNORE_REGISTRATION_TRIGGERS"="0x20"}
      $TASK_CREATE = $TASK_CREATION.Get_Item("TASK_CREATE")
      $XML = '<?xml version="1.0" encoding="UTF-16"?><Task version="1.3" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task"><RegistrationInfo><Date>2018-01-14T10:48:55.1494814</Date><Author>otabut</Author></RegistrationInfo><Triggers><BootTrigger><Enabled>true</Enabled></BootTrigger></Triggers><Principals><Principal id="Author"><UserId>S-1-5-18</UserId><RunLevel>HighestAvailable</RunLevel></Principal></Principals><Settings><MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy><DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries><StopIfGoingOnBatteries>true</StopIfGoingOnBatteries><AllowHardTerminate>true</AllowHardTerminate><StartWhenAvailable>false</StartWhenAvailable><RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable><IdleSettings><StopOnIdleEnd>true</StopOnIdleEnd><RestartOnIdle>false</RestartOnIdle></IdleSettings><AllowStartOnDemand>true</AllowStartOnDemand><Enabled>true</Enabled><Hidden>false</Hidden><RunOnlyIfIdle>false</RunOnlyIfIdle><DisallowStartOnRemoteAppSession>false</DisallowStartOnRemoteAppSession><UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine><WakeToRun>false</WakeToRun><ExecutionTimeLimit>P3D</ExecutionTimeLimit><Priority>7</Priority></Settings><Actions Context="Author"><Exec><Command>C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</Command><Arguments>-NoProfile -ExecutionPolicy ByPass -file "'+$Path+'\PowerLSS.ps1" -LogFile "'+$Path+'\PowerLSS.log"</Arguments></Exec></Actions></Task>'
      $TaskFolder.RegisterTask("\PowerLSS",$XML,$TASK_CREATE,'S-1-5-18',$null,5) | Out-Null
      $Result = "Success"
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
