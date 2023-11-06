# Depends on LoadFunction.ps1
function GetModuleHandleA
{
    param(
        [Parameter(Position = 0,                  )][String] $lpModuleName = ""
    )

	$GetModuleHandleA = LoadFunction kernel32.dll GetModuleHandleA @([IntPtr]) ([IntPtr])

	$lpModuleNameAnsi = [IntPtr]::Zero
	if ($lpModuleName) { $lpModuleNameAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpModuleName) }
	$ret = $GetModuleHandleA.Invoke($lpModuleNameAnsi)
	if ($lpModuleName) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpModuleNameAnsi) }

	return $ret
}
