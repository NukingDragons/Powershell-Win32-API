function LoadLibraryA
{
    param(
        [Parameter(Position = 0, Mandatory = $True)][String] $lpLibFileName
    )

	$LoadLibraryA = LoadFunction kernel32.dll LoadLibraryA @([IntPtr]) ([IntPtr])

	$lpLibFileNameAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpLibFileName)
	$ret = $LoadLibraryA.Invoke($lpLibFileNameAnsi)
	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpLibFileNameAnsi)

	return $ret
}
