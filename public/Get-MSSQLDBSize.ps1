Function Get-MSSQLDBSize{
  <#
      .SYNOPSIS
      retreives the sizes of all databases on the specified MS SQL Server
      .DESCRIPTION

      .PARAMETER Server
      which server to work against, FDQN or shortname/IP accepted - no check if the server is reachable 
      .PARAMETER Version
      which version of SQL server to work against - can be omitted in some cases, curently supports MS SQL Server 2008R2,2012,2014 and 2016
      .NOTES
      Function written by Mattias Blixt - mattiasblixt@gmail.com
      full credit of the idea and base code goes to Tim Smith
      .EXAMPLE
      Get-MSSQLDBSize -Server someserver
      will check after installed SQL libraries, if just one found use it otherwise it will ask the user to rerun the command with an specified version
      .EXAMPLE
      Get-MSSQLDBSize -Server someserver -version 2008R2
      will check if we have an installed library for MS SQL 2008R2 on the local computer, if not will abort execution. if it exists the function will
      connect to the SQL server specified and collect the data.
  #>
  [cmdletbinding()]
  Param(
    [Parameter(mandatory=$true)][ValidateLength(4,150)][string]$Server,
    [ValidateSet('2008R2','2012','2014','2016')][string]$version
  )
  Begin{
    $nl = [Environment]::NewLine
    $criticalerror = $false
  }
  Process{
    $libraryinfo = Get-MSSQLLibrary
    if(!$version){
      if(!$libraryinfo){
        Write-Warning ('no SQL libraries at all found - aborting execution')
        $criticalerror = $true
      }
      elseif($libraryinfo.Count -gt 1){
        Write-Warning 'found more than one SQL installation - specify which one to use with the ''version'' parameter'
        $criticalerror = $true
      }
    }
    else{
      $selectedversion = $libraryinfo | Where-Object {$libraryinfo.VersionNumber -like $version}
      if(!$selectedversion){
        Write-Warning ('the specified SQL library version don''t exists on this machine - terminating execution')
        $criticalerror = $true
      }
    } 
    if(!$criticalerror){
        Write-Host ('Adding libraries for SQL version {0}' -f $version)
        Add-Type -Path $selectedversion.Path
        $sqlsrv = New-Object Microsoft.SqlServer.Management.SMO.Server($Server)

        foreach ($db in $sqlsrv.Databases | Where-Object {$_.id -gt 4}){
          $dbinfo = New-Object PSObject
          $dbinfo | Add-Member -type NoteProperty -name 'SQLServer' -Value $Server
          $dbinfo | Add-Member -type NoteProperty -name 'DBName' -Value $db.Name
          $dbinfo | Add-Member -type NoteProperty -name 'DBSizeGb' -Value ($db.size/1024)

          $dbinfo
        }
      }
  }
}#END Get-MSSQLDBSize