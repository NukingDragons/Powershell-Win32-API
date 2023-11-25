# Depends on LoadFunction.ps1
# Depends on structures/WSAPROTOCOL_INFOW.ps1
function WSASocketW
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][Int32] $af,
		[Parameter(Position = 1, Mandatory = $True)][Int32] $type,
		[Parameter(Position = 2, Mandatory = $True)][Int32] $protocol,
		[Parameter(Position = 3                   )][WSAPROTOCOL_INFOW] $lpProtocolInfo = $null,
		[Parameter(Position = 4                   )][UInt32] $g = 0,
		[Parameter(Position = 5                   )][UInt32] $dwFlags = 0
	)

	if ($global:WSASocketW -eq $null)
	{
		$global:WSASocketW = LoadFunction ws2_32.dll WSASocketW @([Int32], [Int32], [Int32], [IntPtr], [UInt32], [UInt32]) ([UInt64])
	}

	$lpProtocolInfoMem = [IntPtr]::Zero
	if ($lpProtocolInfo) { $lpProtocolInfoMem = $lpProtocolInfo.ToUnmanaged() }

	$ret = $global:WSASocketW.Invoke($af, $type, $protocol, $lpProtocolInfoMem, $g, $dwFlags)

	if ($lpProtocolInfo) { $lpProtocolInfo.FreeUnmanaged($lpProtocolInfoMem) }

	return $ret
}
