# Depends on LoadFunction.ps1
function LoadLibraryW
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][String] $lpLibFileName
	)

	if ($global:LoadLibraryW -eq $null)
	{
		$global:LoadLibraryW = LoadFunction kernel32.dll LoadLibraryW @([IntPtr]) ([IntPtr])
	}

	$lpLibFileNameUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpLibFileName)

	$ret = $global:LoadLibraryW.Invoke($lpLibFileNameUni)

	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpLibFileNameUni)

	return $ret
}
