Function Write-LSS_Log
{
  Param (
    [parameter(Mandatory=$true)][String]$Step,
    [parameter(Mandatory=$true)][ValidateSet("Information","Warning","Error")][String]$Status,
    [parameter(Mandatory=$true)][String]$Comment
  )

  #Format message to log
  $HostName = $env:computername
  $Date = Get-Date -format "dd/MM/yyyy HH:mm:ss.fff"
  $Message = "$Date - $Hostname - $Step - $Status - $Comment"
  
  #Handle Console Output
  if ($Global:ConsoleOutput.IsPresent)
  {
    switch ($Status)
    {
      "Information"
      { 
        Write-Host $Message
      }
      "Warning"
      { 
        Write-Host $Message -ForegroundColor Yellow
      }
      "Error"
      { 
        Write-Host $Message -ForegroundColor Red
      }
    }
  }

  #Handle writing in log file
  if ($Global:LogFile)
  {
    Add-Content $Global:Logfile $Message
  }

  #Handle returned PSCustomObject
  if (($Global:Output.IsPresent) -or ($Global:CustomLogging.IsPresent))
  {
    $Line = [PSCustomObject]@{
      Date = $Date
      Hostname = $HostName
      Step = $Step
      Status = $Status
      Comment = $Comment
    }
    $Global:Log += $Line
  }

  #Handle custom logging function
  if ($Global:CustomLogging.IsPresent)
  {
    Start-LSS_CustomLogging $Line
  }
}
