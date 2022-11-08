<#
.SYNOPSIS
Restarts a restartable session.

.DESCRIPTION
Exits from a restartable session and starts a new restartable session. Throws a non-terminating error when the caller is not in a restartable session.
The ScriptBlock passed to Enter-RSSession is called at the start of the new session.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Restart-RSSession

#>
function Restart-RSSession
{
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdletBinding()]
    param()

    process
    {
        if ([RestartableSession.GlobalVariable]::IsInRestartableSession())
        {
            exit
        }
        else
        {
            Write-Error -Message 'Not in a RS Session.' -Category InvalidOperation
        }
    }
}
