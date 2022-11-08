<div align="center">

# RestartableSession

[![GitHub license](https://img.shields.io/github/license/mdgrs-mei/RestartableSession)](https://github.com/mdgrs-mei/RestartableSession/blob/main/LICENSE)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/p/RestartableSession)](https://www.powershellgallery.com/packages/RestartableSession)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/RestartableSession)](https://www.powershellgallery.com/packages/RestartableSession)

[![Pester Test](https://github.com/mdgrs-mei/RestartableSession/actions/workflows/pester-test.yml/badge.svg)](https://github.com/mdgrs-mei/RestartableSession/actions/workflows/pester-test.yml)

*RestartableSession* is a PowerShell module to instantly and properly reflect the code changes to the module or script you are making. It helps you perform quick interactive testing on the console.

https://user-images.githubusercontent.com/81177095/200330265-cdbcbfa7-ca64-419d-8f06-0c946e562d2d.mp4

</div>

If you have written a PowerShell module, you might have got into some situations where you had to restart the PowerShell session to reflect your code changes, such as changes to classes imported by `using module`, and C# classes added by `Add-Type`. It's annoying if you have to manually restart the session and import the module every time but with *RestartableSession*, you can make the process automatic.

## Requirements

This module has been tested on:

- Windows 10 and 11 
- Windows PowerShell 5.1 and PowerShell 7.2

> **Warning**
> It only runs on the ConsoleHost and does not support Windows PowerShell ISE Host or Visual Studio Code Host.

## Installation

*RestartableSession* is available on the PowerShell Gallery. You can install the module with the following command:

```powershell
Install-Module -Name RestartableSession -Scope CurrentUser
```

## Usage

By calling `Enter-RSSession`, you enter a restartable session. The specified script block is called every time the session is restarted. `RS(n)` is added to the prompt to indicate that you are in a restartable session and how many times you restarted the session. 

```powershell
PS C:\> Enter-RSSession -OnStart {"Hello"}
Hello
RS(1) PS C:\> 
```

Inside the restartable session, you can restart the session by calling `Restart-RSSession` function.

```powershell
RS(1) PS C:\> Restart-RSSession
Hello
RS(2) PS C:\> 
```

`Start-RSRestartFileWatcher` is used to automatically call `Restart-RSSession` on file saves. 

```powershell
RS(2) PS C:\> Start-RSRestartFileWatcher -Path D:\ScriptModuleTest -IncludeSubdirectories
```

Finally, when you've done with the module development, you can return to the caller session by `Exit-RSSession`.

```powershell
RS(2) PS C:\> Exit-RSSession
PS C:\>
```

## Use Cases

### Script Module development

Assuming that all the code used for the module is placed under one directory, you can set up a auto-reloading console by calling this function.

```powershell
function StartScriptModuleDevelopment($ModuleDirectory)
{
    $onStart = {
        param($dir)
        Import-Module $dir
        Start-RSRestartFileWatcher -Path $dir -IncludeSubdirectories
    }
    Enter-RSSession -OnStart $onStart -ArgumentList $ModuleDirectory
}
```

### Script Class Module development

If the module exports classes, you need `using module` statement to import the module. In order to use `using module` inside a script block, you have to create the script block from a string. The video at the top of this page was made using this function.

```powershell
function StartScriptClassModuleDevelopment($ModuleDirectory)
{
    $scriptBlockString = 
@'
    using module {0}
    Start-RSRestartFileWatcher -Path {0} -IncludeSubdirectories
'@
    $onStart = [ScriptBlock]::Create($scriptBlockString -f $ModuleDirectory)
    Enter-RSSession -OnStart $onStart
}
```

### Binary Module development

`$OnStart` script block could be anything so you can even build a .Net project once the code has been changed and reload the dll. The session is restarted at the source code change so there is no dll blocking issue.

```powershell
function StartBinaryModuleDevelopment($DotNetProjectDirectory, $DllPath)
{
    $onStart = {
        param($projectDir, $dll)
        dotnet build $projectDir
        Import-Module $dll
        Start-RSRestartFileWatcher -Path $projectDir -IncludeSubdirectories
    }
    Enter-RSSession -OnStart $onStart -ArgumentList $DotNetProjectDirectory, $DllPath
}
```

https://user-images.githubusercontent.com/81177095/200581798-56271cf6-ced4-409b-b043-7e7563e89687.mp4

