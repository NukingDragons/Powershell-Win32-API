# Depends on LoadFunction.ps1
# Depends on structures/WSADATA.ps1
function WSAStartup
{
    param(
        [Parameter(Position = 0, Mandatory = $True)][UInt16] $wVersionRequired,
        [Parameter(Position = 1, Mandatory = $True)][WSADATA] $lpWSAData
    )

	if ($global:WSAStartup -eq $null)
	{
		$global:WSAStartup = LoadFunction ws2_32.dll WSAStartup @([UInt16], [IntPtr]) ([Int32])
	}

	$lpWSADataMem = $lpWSAData.ToUnmanaged()

	$ret = $global:WSAStartup.Invoke($wVersionRequired, $lpWSADataMem)

	$lpWSAData.FromUnmanaged($lpWSADataMem) | Out-Null
	$lpWSAData.FreeUnmanaged($lpWSADataMem)

	return $ret
}
