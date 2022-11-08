#Requires -Modules PSScriptAnalyzer

BeforeAll {
    $moduleDir = "$PSScriptRoot\..\RestartableSession\"
}

Describe 'RestartableSession' {
    It 'shows no warnings and errors of PSScriptAnalyzer' {
        $result = Invoke-ScriptAnalyzer -Path $moduleDir -Recurse
        $result | Out-String | Write-Host
        $result.Count | Should -Be 0
    }
}


