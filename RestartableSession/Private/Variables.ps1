
# A global variable also works but we use C# class to hide the variable from users as much as possible.
Add-Type -TypeDefinition @'
using System.Management.Automation;

namespace RestartableSession {

public class GlobalVariable
{
    // Magic exit code to break the loop
    public const int kExitCodeToBreak = 8981;

    public static string PromptPrefix = "";
    public static ScriptBlock OriginalPromptFunction;

    public static bool IsInRestartableSession()
    {
        return !System.String.IsNullOrEmpty(PromptPrefix);
    }
}

}
'@
