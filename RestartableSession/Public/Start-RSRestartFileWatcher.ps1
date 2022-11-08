<#
.SYNOPSIS
Starts a FileSystemWatcher that triggers Restart-RSSession.

.DESCRIPTION
Starts a FileSystemWatcher that triggers Restart-RSSession when a specified directory is changed.
Throws a non-terminating error when the caller is not in a restartable session.

.PARAMETER Path
Path of the directory to watch. It follows the spec of FileSystemWatcher's Path property.

.PARAMETER Filter
Filter string used to determine what files are monitored in a directory. It follows the spec of FileSystemWatcher's Filter property.
The default is '*.*' (Watches all files.) '*.txt' watches the files whose extension is '.txt'.

.PARAMETER IncludeSubdirectories
Switch that indicates whether subdirectories of the specified directory should be monitored.

.PARAMETER PassThru
The function returns a watcher object if this switch is specified.

.INPUTS
None.

.OUTPUTS
PSCustomObject if PassThru is specified. An object that represents a watcher.

.EXAMPLE
# Monitors all files in a directory including subdirectories.
Start-RSRestartFileWatcher -Path D:\ScriptModuleTest -IncludeSubdirectories

.EXAMPLE
# Monitors ps1 and psm1 files in a directory including subdirectories.
Start-RSRestartFileWatcher -Path D:\ScriptModuleTest -Filter '*.ps1' -IncludeSubdirectories
Start-RSRestartFileWatcher -Path D:\ScriptModuleTest -Filter '*.psm1' -IncludeSubdirectories

.EXAMPLE
# Monitors all files in a directory and stores the watcher object to stop it later.
$watcher = Start-RSRestartFileWatcher -Path D:\ScriptModuleTest -PassThru

.LINK
https://learn.microsoft.com/en-us/dotnet/api/system.io.filesystemwatcher?view=net-7.0

#>
function Start-RSRestartFileWatcher
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [String]$Path,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [String]$Filter,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch]$IncludeSubdirectories,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch]$PassThru
    )

    process
    {
        if (-not [RestartableSession.GlobalVariable]::IsInRestartableSession())
        {
            Write-Error -Message 'Not in a RS Session.' -Category InvalidOperation
            return
        }

        $fileSystemWatcher = New-Object System.IO.FileSystemWatcher
        $fileSystemWatcher.Path = $Path
        $fileSystemWatcher.Filter = $Filter
        $fileSystemWatcher.IncludeSubdirectories = $IncludeSubdirectories
        $fileSystemWatcher.EnableRaisingEvents = $true
        $fileSystemWatcher.NotifyFilter = 'FileName, DirectoryName, LastWrite'

        $action = {
            $process = Get-Process -Id $Event.MessageData -ErrorAction Ignore
            if ($process)
            {
                Stop-Process $process
            }
        }

        $watcher = [PSCustomObject]@{
            FileSystemWatcher = $fileSystemWatcher
            Created = Register-ObjectEvent $fileSystemWatcher 'Created' -Action $action -MessageData $PID
            Changed = Register-ObjectEvent $fileSystemWatcher 'Changed' -Action $action -MessageData $PID
            Deleted = Register-ObjectEvent $fileSystemWatcher 'Deleted' -Action $action -MessageData $PID
            Renamed = Register-ObjectEvent $fileSystemWatcher 'Renamed' -Action $action -MessageData $PID
        }

        if ($PassThru)
        {
            $watcher
        }
    }
}
