
# A global variable also works but we use C# class to hide the variable from users as much as possible.
Add-Type -TypeDefinition @'
using System.Management.Automation;

namespace RestartableSession {

public class GlobalVariable
{
    public const int kExitCodeToBreak = 0;
    public const int kExitCodeToRestart = 1;

    public static bool IsDevMode = false;
    public static string PromptPrefix = "";
    public static ScriptBlock OriginalPromptFunction;

    public static bool IsInRestartableSession()
    {
        return !System.String.IsNullOrEmpty(PromptPrefix);
    }
}

}
'@
