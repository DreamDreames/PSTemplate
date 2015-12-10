Param(
    [parameter(Mandatory = $true)] $command
)

$root = Split-Path $MyInvocation.MyCommand.Path
Import-Module "$root\Pester\Pester.psm1"
#. $root\PsTemplate.ps1
Import-Module "$root\PsTemplate.psm1" -Force

if( $command -ieq "test"){
    ls -filter *.ps1 "$root\tests" | % {. $_.FullName}
}
