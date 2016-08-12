#Author: Mattias Blixt - mattiasblixt[at]gmail[dot]com

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Get-MSSQLLibrary' {
  Context 'Library 100 dont exists and no other does either' {
    #Mock Get-ChildItem { return @{FullName = "A_File.TXT"} } -ParameterFilter { $Path -and $Path.StartsWith($env:temp) }
    Mock Test-Path {return $false }
    It 'dont finds any SQL Libraries' {
      Get-MSSQLLibrary -Verbose | should be $null
    }
  }
  Context 'Library 100 exists but no other'{
    Mock Test-Path {return $true } -ParameterFilter {$Path -match '100'}
    $var = Get-MSSQLLibrary
    It 'function returns object' {
      $var | Should be $true
    }
    It "function returned '100' in returned oject property 'VersionCode'" {
      $var.versioncode | should be 100
    }
    It "function returned '2008R2' in returned oject property 'VersionNumber'" {
      $var.versionnumber | should be 2008R2
    }
    It 'function returned correct object' {
      $var.VersionCode | should be '100'
      $var.VersionNumber | should be '2008R2'
      $var.Path | should be 'C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'
    }
  }
  Context 'Library 100 exists and so does library 130'{
    Mock Test-Path {return $true } -ParameterFilter {$Path -match '100'}
    Mock Test-Path {return $true } -ParameterFilter {$Path -match '130'}
    $var = Get-MSSQLLibrary
    It 'function returns object'{
      $var | should be $true
    }
    It 'function returns two object rows'{
      $var.count | Should Be 2
    }
    It "function returned '100' in first returned object property 'VersionCode'" {
      $var[0].VersionCode | should be 100
    }
    It "function returned '2008R2' in first returned object property 'VersionNumber'" {
      $var[0].VersionNumber | should be 2008R2
    }
    It "function returned '130' in second returned object property 'VersionCode'" {
      $var[1].versioncode | should be 130
    }
    It "function returned '2016' in second returned object property 'VersionNumber'" {
      $var[1].VersionNumber | should be 2016
    }
  }
}