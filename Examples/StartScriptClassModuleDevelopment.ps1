# Start auto restart for development of script modules that expose PowerShell classes.
# When any file in the module directory is changed, a new session is started and the module is imported by 'using module' statement automatically.

param
(
    [Parameter(Mandatory=$true)]
    $ModuleDirectory
)

Import-Module "$PSScriptRoot\..\RestartableSession"

# Note that in order to use 'using module' inside a script block, you need to create the script block from a string.
$onStart = [ScriptBlock]::Create(@'
    using module {0}
    Start-RSRestartFileWatcher -Path {0} -IncludeSubdirectories
'@ -f $ModuleDirectory)

Enter-RSSession -OnStart $onStart -ShowProcessId
