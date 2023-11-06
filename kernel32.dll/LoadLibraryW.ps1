# Depends on LoadFunction.ps1
function LoadLibraryW
{
    param(
        [Parameter(Position = 0, Mandatory = $True)][String] $lpLibFileName
    )

	$LoadLibraryW = LoadFunction kernel32.dll LoadLibraryW @([IntPtr]) ([IntPtr])

	$lpLibFileNameUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpLibFileName)
	$ret = $LoadLibraryW.Invoke($lpLibFileNameUni)
	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpLibFileNameUni)

	return $ret
}
