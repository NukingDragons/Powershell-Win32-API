# Depends on LoadFunction.ps1
function GetProcAddress
{
    param(
        [Parameter(Position = 0, Mandatory = $True)][IntPtr] $hModule,
        [Parameter(Position = 1, Mandatory = $True)][String] $lpProcName
    )

	$GetProcAddress = LoadFunction kernel32.dll GetProcAddress @([IntPtr], [IntPtr]) ([IntPtr])

	$lpProcNameAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpProcName)
	$ret = $GetProcAddress.Invoke($hModule, $lpProcNameAnsi)
	[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpProcNameAnsi)

	return $ret
}
