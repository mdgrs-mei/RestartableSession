<#
.SYNOPSIS
Stops a FileSystemWatcher that triggers Restart-RSSession.

.DESCRIPTION
Stops the specified FileSystemWatcher that triggers Restart-RSSession.
Throws a non-terminating error when the caller is not in a restartable session.
The stopped watcher cannot be used anymore.

.PARAMETER InputObject
A watcher object that is returned by Start-RSRestartFileWatcher.

.INPUTS
PSCustomObject. An object that represents a watcher.

.OUTPUTS
None.

.EXAMPLE
$watcher = Start-RSRestartFileWatcher -Path D:\ScriptModuleTest -PassThru
$watcher | Stop-RSRestartFileWatcher

#>
function Stop-RSRestartFileWatcher
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [PSCustomObject]$InputObject
    )

    process
    {
        if (-not [RestartableSession.GlobalVariable]::IsInRestartableSession())
        {
            Write-Error -Message 'Not in a RS Session.' -Category InvalidOperation
            return
        }

        $watcher = $InputObject

        Stop-Job $watcher.Created
        Stop-Job $watcher.Changed
        Stop-Job $watcher.Deleted
        Stop-Job $watcher.Renamed
        $watcher.FileSystemWatcher.Dispose()

        $watcher.Created = $null
        $watcher.Changed = $null
        $watcher.Deleted = $null
        $watcher.Renamed = $null
        $watcher.FileSystemWatcher = $null
    }
}
