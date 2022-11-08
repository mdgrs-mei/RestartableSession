<#
.SYNOPSIS
Exits from a restartable session.

.DESCRIPTION
Exits from a restartable session. Throws a non-terminating error when the caller is not in a restartable session.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Exit-RSSession

#>
function Exit-RSSession
{
    [CmdletBinding()]
    param()

    process
    {
        if ([RestartableSession.GlobalVariable]::IsInRestartableSession())
        {
            exit [RestartableSession.GlobalVariable]::kExitCodeToBreak
        }
        else
        {
            Write-Error -Message 'Not in a RS Session.' -Category InvalidOperation
        }
    }
}
