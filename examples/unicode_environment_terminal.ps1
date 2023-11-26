# Depends on kernel32.dll/CreateProcessA.ps1
# Depends on structures/STARTUPINFOA.ps1
# Depends on structures/PROCESS_INFORMATION.ps1

$StartupInfo = [STARTUPINFOA]::new()
$ProcessInfo = [PROCESS_INFORMATION]::new()
$CommandLine = "cmd.exe"

[String[]] $EnvVars = @("CustomVar1=Value", "CustomVar2=Value")

CreateProcessA -lpCommandLine ([ref]$CommandLine) -bInheritHandles $False -lpStartupInfo $StartupInfo -lpProcessInformation $ProcessInfo -dwCreationFlags CREATE_NEW_CONSOLE, CREATE_UNICODE_ENVIRONMENT -lpEnvironment $EnvVars
