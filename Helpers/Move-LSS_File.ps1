Function Move-LSS_File
{
  Param (
    [parameter(Mandatory=$true)][String]$File,
    [parameter(Mandatory=$true)][String]$Target
  )

  #Test existence of folder and create it if missing
  if (!(Test-Path -Path $Target))
  {
    New-Item -Path $Target -ItemType Directory | out-null
  }
  #Move script that has been processed
  Move-Item $File $Target -Force
}
