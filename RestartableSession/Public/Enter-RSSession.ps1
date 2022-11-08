<#
.SYNOPSIS
Enters a new restartable PowerShell session.

.DESCRIPTION
Enters a new restartable PowerShell session. Throws a non-terminating error when the caller is already in a restartable session or the host is not a ConsoleHost.
The PowerShell executable that called this function is used to create a new session.

.PARAMETER OnStart
ScriptBlock that is called at the start of the restartable session.

.PARAMETER ArgumentList
An array of arguments that is passed to the OnStart script block.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Enter-RSSession -OnStart {'Hi'}

.EXAMPLE
# Automatically restart a session and reload the module on file save.
$onStart = {
    param($modulePath)
    Import-Module $modulePath
    Start-RSRestartFileWatcher -Path $modulePath -IncludeSubdirectories
}
Enter-RSSession -OnStart $onStart -ArgumentList D:\ScriptModuleTest

#>
function Enter-RSSession
{
    [CmdletBinding(DefaultParameterSetName='NoOnStart')]
    param
    (
        [Parameter(ParameterSetName='NoOnStart', Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='OnStart', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ScriptBlock]$OnStart,

        [Parameter(ParameterSetName='OnStart', ValueFromPipelineByPropertyName=$true)]
        [Object[]]$ArgumentList
    )

    process
    {
        if ([RestartableSession.GlobalVariable]::IsInRestartableSession())
        {
            Write-Error -Message 'Already in a RS Session.' -Category InvalidOperation
            return
        }

        if ($host.Name -ne 'ConsoleHost')
        {
            Write-Error -Message 'Only ConsoleHost is supported.' -Category InvalidOperation
            return
        }

        $powershellExe = (Get-Process -Id $PID).Path
        $command = {
            # This is executed in the created new session scope.
            # Don't use any temporary variables as they are visible to users.

            Import-Module $args[0]
            [RestartableSession.GlobalVariable]::RestartCount = $args[1]
            [RestartableSession.GlobalVariable]::OriginalPromptFunction = (Get-Command Prompt).ScriptBlock

            function Prompt
            {
                $restartCount = [RestartableSession.GlobalVariable]::RestartCount
                "RS($restartCount) " + [RestartableSession.GlobalVariable]::OriginalPromptFunction.Invoke()
            }

            if ($args[2])
            {
                if ($args.Length -gt 3)
                {
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($args[2])) -NoNewScope -ArgumentList $args[3..($args.Length-1)]
                }
                else
                {
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($args[2])) -NoNewScope
                }
            }
        }

        $restartCount = 1
        while ($true)
        {
            $arguments = @("$PSScriptRoot\..", $restartCount, $OnStart) + $ArgumentList

            & $powershellExe -NoExit -Command $command -Args $arguments

            if ($LASTEXITCODE -eq [RestartableSession.GlobalVariable]::kExitCodeToBreak)
            {
                break
            }
            ++$restartCount
        }
    }
}
