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

.PARAMETER ShowProcessId
Switch to specify if the process ID of the restartable session is shown in the prompt.

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
        [Object[]]$ArgumentList,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch]$ShowProcessId
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

            Import-Module RestartableSession

            if ($args.showProcessId)
            {
                [RestartableSession.GlobalVariable]::PromptPrefix += 'RS({0})[{1}] ' -f $args.restartCount, $PID
            }
            else
            {
                [RestartableSession.GlobalVariable]::PromptPrefix = 'RS({0}) ' -f $args.restartCount
            }
            [RestartableSession.GlobalVariable]::OriginalPromptFunction = (Get-Command Prompt).ScriptBlock

            function Prompt
            {
                [RestartableSession.GlobalVariable]::PromptPrefix + [RestartableSession.GlobalVariable]::OriginalPromptFunction.Invoke()
            }

            if ($args.onStart)
            {
                if ($args.onStartArgumentList)
                {
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($args.onStart)) -NoNewScope -ArgumentList $args.onStartArgumentList
                }
                else
                {
                    Invoke-Command -ScriptBlock ([ScriptBlock]::Create($args.onStart)) -NoNewScope
                }
            }
        }

        $restartCount = 1
        while ($true)
        {
            $arguments = @{
                restartCount = $restartCount
                showProcessId = ($ShowProcessId -eq $true)
                onStart = $OnStart
                onStartArgumentList = $ArgumentList
            }

            & $powershellExe -NoExit -Command $command -Args $arguments

            if ($LASTEXITCODE -eq [RestartableSession.GlobalVariable]::kExitCodeToBreak)
            {
                break
            }
            ++$restartCount
        }
    }
}
