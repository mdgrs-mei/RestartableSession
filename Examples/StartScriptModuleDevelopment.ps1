# Start auto restart for script module development.
# When any file in the module directory is changed, a new session is started and the module is imported automatically.

param
(
    [Parameter(Mandatory=$true)]
    $ModuleDirectory
)

Import-Module "$PSScriptRoot\..\RestartableSession"

$onStart = {
    param($dir)
    Import-Module $dir
    Start-RSRestartFileWatcher -Path $dir -IncludeSubdirectories
}

Enter-RSSession -OnStart $onStart -ArgumentList $ModuleDirectory
