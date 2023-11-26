# Depends on kernel32.dll/CreateProcessA.ps1
# Depends on structures/STARTUPINFOA.ps1
# Depends on structures/PROCESS_INFORMATION.ps1

$StartupInfo = [STARTUPINFOA]::new()
$ProcessInfo = [PROCESS_INFORMATION]::new()
$CommandLine = "calc.exe"

CreateProcessA -lpCommandLine ([ref]$CommandLine) -bInheritHandles $False -dwCreationFlags 0 -lpStartupInfo $StartupInfo -lpProcessInformation $ProcessInfo
