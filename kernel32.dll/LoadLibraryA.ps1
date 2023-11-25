# Depends on LoadFunction.ps1
function LoadLibraryA
{
    param(
        [Parameter(Position = 0, Mandatory = $True)][String] $lpLibFileName
    )

	if ($global:LoadLibraryA -eq $null)
	{
		$global:LoadLibraryA = LoadFunction kernel32.dll LoadLibraryA @([IntPtr]) ([IntPtr])
	}

	$lpLibFileNameAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpLibFileName)

	$ret = $global:LoadLibraryA.Invoke($lpLibFileNameAnsi)

	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpLibFileNameAnsi)

	return $ret
}
