#Author: Mattias Blixt - mattiasblixt[at]gmail[dot]com

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe 'Return-MSSQLObject' {
    Context 'NO SQL libraries exists' {
    Mock Get-MSSQLLibrary {return @()}
        It 'outputs error message' {
            Return-MSSQLObject | Should Be $null
        }
    }
    Context 'More than one SQL library exists' {
    $object = @()
    $object += New-Object PSObject -Property @{'VersionCode' = 100
    'VersionNumber' = '2008R2'}
    $object += New-Object PSObject -Property @{'VersionCode' = 130
    'VersionNumber' = '2016'}
    Mock Get-MSSQLLibrary {return $object}
        It 'Should output error message' {
            Return-MSSQLObject | Should Be $null
        }
    }
    Context 'Selected SQL library dont exist on machine' {
    $object = @()
    $object += New-Object PSObject -Property @{'VersionCode' = 100
    'VersionNumber' = '2008R2'}
    Mock Get-MSSQLLibrary {return $object}
        It 'Should output error message' {
            Return-MSSQLObject -version 2016 | Should Be $null
        }
    }
}