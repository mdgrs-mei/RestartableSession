param($devMode)

$privateScripts = @(Get-ChildItem $PSScriptRoot\Private\*.ps1)
$publicScripts = @(Get-ChildItem $PSScriptRoot\Public\*.ps1)
foreach ($script in ($privateScripts + $publicScripts))
{
    . $script.FullName
}
[RestartableSession.GlobalVariable]::IsDevMode = $devMode

Export-ModuleMember -Function $publicScripts.BaseName
