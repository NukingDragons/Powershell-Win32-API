# Depends on LoadFunction.ps1
# Depends on enums/HKEY.ps1
# Depends on enums/REGSAM.ps1
# Depends on enums/REG_KEY_OPTIONS.ps1
function RegOpenKeyExA
{
	param(
		[Parameter(Position = 0, Mandatory = $True)]
		[HKEY] $hKey = $null,

		[Parameter(                               )]
		[String] $lpSubKey = $null,

		[Parameter(Position = 1, Mandatory = $True)]
		[REG_KEY_OPTIONS] $ulOptions = 0,

		[Parameter(Position = 2, Mandatory = $True)]
		[REGSAM] $samDesired = $null,

		[Parameter(Position = 3, Mandatory = $True)]
		[ValidateScript({
			if($_.Value.GetType().Name -eq "IntPtr")
			{
				return $true
			}
			else
			{
				throw "Expected an IntPtr by reference"
			}
			})]
		[ref] $phkResult
	)

	if ($global:RegOpenKeyExA -eq $null)
	{
		$global:RegOpenKeyExA = LoadFunction kernel32.dll RegOpenKeyExA @([IntPtr], [IntPtr], [UInt32], [UInt32], [IntPtr]) ([UInt32])
	}

	$lpSubKeyAnsi = [IntPtr]::Zero
	$phkResultMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal([System.IntPtr]::Size)

	if ($lpSubKey.Length -gt 0) { $lpSubKeyAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpSubKey) }

	$ret = $global:RegOpenKeyExA.Invoke(([Int32]$hKey), $lpSubKeyAnsi, ([UInt32]$ulOptions), ([UInt32]$samDesired), $phkResultMem)

	if ($lpSubKey.Length -gt 0) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpSubKeyAnsi) }

	[IntPtr[]] $Pointer = @([IntPtr]::Zero)

	[System.Runtime.InteropServices.Marshal]::Copy($phkResultMem, $Pointer, 0, $Pointer.Length)
	$phkResult.Value = $Pointer[0]

	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($phkResultMem)

	return $ret
}
