# Depends on LoadFunction.ps1
# Depends on structures/WSAPROTOCOL_INFOA.ps1
function WSASocketA
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][Int32] $af,
		[Parameter(Position = 1, Mandatory = $True)][Int32] $type,
		[Parameter(Position = 2, Mandatory = $True)][Int32] $protocol,
		[Parameter(Position = 3                   )][WSAPROTOCOL_INFOA] $lpProtocolInfo = $null,
		[Parameter(Position = 4                   )][UInt32] $g = 0,
		[Parameter(Position = 5                   )][UInt32] $dwFlags = 0
	)

	if ($global:WSASocketA -eq $null)
	{
		$global:WSASocketA = LoadFunction ws2_32.dll WSASocketA @([Int32], [Int32], [Int32], [IntPtr], [UInt32], [UInt32]) ([UInt64])
	}

	$lpProtocolInfoMem = [IntPtr]::Zero
	if ($lpProtocolInfo) { $lpProtocolInfoMem = $lpProtocolInfo.ToUnmanaged() }

	$ret = $global:WSASocketA.Invoke($af, $type, $protocol, $lpProtocolInfoMem, $g, $dwFlags)

	if ($lpProtocolInfo) { $lpProtocolInfo.FreeUnmanaged($lpProtocolInfoMem) }

	return $ret
}
