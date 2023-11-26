# Depends on kernel32.dll/CreateProcessA.ps1
# Depends on structures/STARTUPINFOA.ps1
# Depends on structures/PROCESS_INFORMATION.ps1

$StartupInfo = [STARTUPINFOA]::new()
$ProcessInfo = [PROCESS_INFORMATION]::new()
$CommandLine = "cmd.exe"

# h4ck3r t3rm1n41 w00000000000
$StartupInfo.dwFlags = [STARTUPINFO_FLAGS]::STARTF_USEFILLATTRIBUTE
$StartupInfo.dwFillAttribute = [STARTUPINFO_FILLATTRIBUTES]::FOREGROUND_GREEN

CreateProcessA -lpCommandLine ([ref]$CommandLine) -bInheritHandles $False -lpStartupInfo $StartupInfo -lpProcessInformation $ProcessInfo -dwCreationFlags CREATE_NEW_CONSOLE
