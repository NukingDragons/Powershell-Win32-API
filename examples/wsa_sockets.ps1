# Depends on ws2_32.dll/WSAStartup.ps1
# Depends on ws2_32.dll/WSASocketA.ps1
# Depends on ws2_32.dll/WSAConnect.ps1
# Depends on ws2_32.dll/htons.ps1
# Depends on ws2_32.dll/inet_addr.ps1
# Depends on structures/SOCKADDR_IN.ps1
# Depends on structures/WSADATA.ps1

$server = [SOCKADDR_IN]::new()

$server.sin_family = 2
$server.sin_port = htons 1337
$server.sin_addr.s_addr = inet_addr "127.0.0.1"

WSAStartup 0x0202 ([WSADATA]::new())
$socket = WSASocketA 2 1 6
WSAConnect $socket $server $server.Size()
