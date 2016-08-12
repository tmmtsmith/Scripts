$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Get-MSSQLDBSize' {
  Context 'No libraries exists' {
    Mock Get-MSSQLLibrary {return $null }
    It 'dont finds any SQL Libraries' {
      Get-MSSQLDBSize -Server localhost | should be $null
    }
  }
  Context 'library for 2012 called don''t exists' {
    Mock Get-MSSQLLibrary {return @{VersionCode='100'; VersionNumber='2008R2'; Path='C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'} }
    It 'asks for server 2012 dont exists' {
      Get-MSSQLDBSize -Server localhost -version 2012 | should be $null
    }
  }
  Context 'library for 2008R2 called - library exists' {
    Mock Get-MSSQLLibrary {return @{VersionCode='100'; VersionNumber='2008R2'; Path='C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'} }
    Mock Add-Type {return $true }
    Mock New-Object {return $true} -ParameterFilter {$TypeName -match 'SqlServer'}
    It 'asks for server 2008R2 - exists - should return object' {
      Get-MSSQLDBSize -Server localhost -version 2008R2 | should be $true
    }
  }
}