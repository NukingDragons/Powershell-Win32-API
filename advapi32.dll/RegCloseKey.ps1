# Depends on LoadFunction.ps1
function RegCloseKey
{
	param(
		[Parameter(Position = 0, Mandatory = $True)]
		[IntPtr] $hKey = $null
	)

	if ($global:RegCloseKey -eq $null)
	{
		$global:RegCloseKey = LoadFunction kernel32.dll RegCloseKey @([IntPtr]) ([UInt32])
	}

	$ret = $global:RegCloseKey.Invoke($hKey)

	return $ret
}
