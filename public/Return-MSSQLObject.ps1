Function Return-MSSQLObject{
  <#
      .SYNOPSIS
      downloads objects to disk to keep track of changes on database objects
      .DESCRIPTION

      .PARAMETER Server
      which server to work against, FDQN or shortname/IP accepted - no check if the server is reachable 
      .PARAMETER Database
      which data base to work against - no checks yet implemented if database is accessible
      .PARAMETER Objects
      which object type to retreive
      .PARAMETER Name
      The name of the object you wish to reteive
      .PARAMETER OutfilePath
      where you wish to store the returned database object
      .NOTES
      from https://www.mssqltips.com/sqlservertip/4310/simple-tsql-code-comparison-with-powershell/
      full credit of the code goes to Tim Smith, just expanded his code a bit
      .EXAMPLE
      Return-MSSQLObject -OutfilePath 'C:\Files\' -Name 'stpCompare'
      will look into the folder c:\files and try to find the two latest written files which fit the regex pattern stpCompare_\d{8}_\d{4}
      if not two files is found an error will occur and execution will be terminated, otherwise the files will be loaded into memory and converter to HTML and line for line
      compared, if they differ they will show up as BOLD in the right hand column output will be saved as an html file in the same folder as specified in Path
  #>
  [cmdletbinding()]
  Param(
    [ValidateLength(3,200)][string]$Server,
    [ValidateLength(3,200)][string]$database,
    [ValidateLength(3,200)][string]$objects,
    [ValidateLength(3,300)][string]$name,
    [ValidateLength(3,500)][string]$outfilepath = 'c:\sqlcompareobjects\',
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
      $now = [datetime]::Now.Tostring('yyyyMMdd_HHmm') # ISO standard form of date time

      $outfile = $outfilepath + $name + '_' + $now + '.sql'
      $newitem = $sqlsrv.Databases["$database"].$objects["$name"].Script()
      $previousitempath = Get-ChildItem -Path $outfilepath | Where-Object {$_.Fullname -match ($name+'_\d{8}_\d{4}')} | Sort-Object {$_.LastWriteTime} -Descending |  Select-Object -first 1 -ExpandProperty FullName
      if(!$previousitempath){
        $create_a_new_item = $true
      }
      else{
        $previousitem = Get-Content $previousitempath
        $newitem | Out-File $env:TEMP+'\'+$name
        $currentitem = Get-Content -Path ($env:TEMP+'\'+$name)
        if((Compare-Object -ReferenceObject $previousitem -DifferenceObject $currentitem | Select-Object SideIndicator -ExpandProperty SideIndicator).count -gt 0){
          $create_a_new_item = $true
          Remove-Item -Path $env:TEMP+'\'+$name -Force
        }else{
          Write-Host ('New and old object is the same - no need to write a new one')
        }
      }

      if($create_a_new_item){
        $newitem | Out-File $outfile
      }
    }
  }
}# END Return-MSSQLObject