# Start auto restart for binary module development.
# When any file in the .Net project directory is changed, a new session is started, the project is built and the dll is imported automatically.

param
(
    [Parameter(Mandatory=$true)]
    $DotNetProjectDirectory,

    [Parameter(Mandatory=$true)]
    $DllPath
)

$devMode = $true
Import-Module "$PSScriptRoot\..\RestartableSession" -ArgumentList $devMode

$onStart = {
    param($projectDir, $dll)
    dotnet build $projectDir
    Import-Module $dll
    Start-RSRestartFileWatcher -Path $projectDir -IncludeSubdirectories
}

Enter-RSSession -OnStart $onStart -OnStartArgumentList $DotNetProjectDirectory, $DllPath -ShowProcessId
