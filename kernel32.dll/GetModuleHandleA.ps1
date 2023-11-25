# Depends on LoadFunction.ps1
function GetModuleHandleA
{
    param(
        [Parameter(Position = 0,                  )][String] $lpModuleName = ""
    )

	if ($global:GetModuleHandleA -eq $null)
	{
		$global:GetModuleHandleA = LoadFunction kernel32.dll GetModuleHandleA @([IntPtr]) ([IntPtr])
	}

	$lpModuleNameAnsi = [IntPtr]::Zero
	if ($lpModuleName) { $lpModuleNameAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpModuleName) }

	$ret = $global:GetModuleHandleA.Invoke($lpModuleNameAnsi)

	if ($lpModuleName) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpModuleNameAnsi) }

	return $ret
}
