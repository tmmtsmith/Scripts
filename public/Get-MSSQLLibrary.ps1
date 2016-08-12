Function Get-MSSQLLibrary{
  <#
      .SYNOPSIS
      collects information on all SQL librabies installed on the local computer 
      .DESCRIPTION
      if one or more SQL libraries is installed will return an object with the following info: VersionCode,VersionNumber,Path
      supports currently the following versions of MS SQL 2008R2,2012,2014 and 2016
      if no SQL libraries found nothing will be returned from the function
      .NOTES
      Author: Mattias Blixt - mattiasblixt[at]gmail[dot]com
      .EXAMPLE
      Get-MSSQLLibrary
      will check after installed SQL libraries on the local computer and return an object with one or more rows if any found, if none found nothing is returned
  #>
  [cmdletbinding()]
  param()
  $versioncode = ('100','110','120','130')
  $versionumber = ('2008R2','2012','2014','2016')
  $prepath = 'C:\Program Files (x86)\Microsoft SQL Server\'
  $postpath = '\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'

  $foundversions = @()
  $versioncode | ForEach-Object {
    Write-Verbose ('testing path {0}' -f ($prepath+$_+$postpath))
    if(Test-Path -Path ($prepath+$_+$postpath)){
      $update = New-Object PSObject
      $update | Add-Member -type NoteProperty -Name 'VersionCode' -Value $_
      $update | Add-Member -type NoteProperty -Name 'VersionNumber' -Value ($versionumber[$versioncode.indexof($_)])
      $update | Add-Member -type NoteProperty -Name 'Path' -Value ($prepath+$_+$postpath)

      $foundversions += $update
      Write-Verbose ('Adding info for SQL library version {0}' -f $update.VersionNumber)
    }
  }
  if(!$foundversions){
    Write-Verbose 'No SQL installation libraries found'
  }
  elseif($foundversions.Count -gt 1){
    Write-Verbose 'found more than one SQL installation library'
  }
  $foundversions
} #END Get-MSSQLLibrary