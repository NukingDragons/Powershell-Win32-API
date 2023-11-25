# Depends on LoadFunction.ps1
function inet_addr
{
    param(
        [Parameter(Position = 0, Mandatory = $True)][String] $cp
    )

	if ($global:inet_addr -eq $null)
	{
		$global:inet_addr = LoadFunction ws2_32.dll inet_addr @([IntPtr]) ([UInt32])
	}

	$cpAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($cp)

	$ret = $global:inet_addr.Invoke($cpAnsi)

	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($cpAnsi)

	return $ret
}
