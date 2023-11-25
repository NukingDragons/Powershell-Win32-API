# Depends on LoadFunction.ps1
function GetModuleHandleW
{
    param(
        [Parameter(Position = 0,                  )][String] $lpModuleName = ""
    )

	if ($global:GetModuleHandleW -eq $null)
	{
		$global:GetModuleHandleW = LoadFunction kernel32.dll GetModuleHandleW @([IntPtr]) ([IntPtr])
	}

	$lpModuleNameUni = [IntPtr]::Zero
	if ($lpModuleName) { $lpModuleNameUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpModuleName) }

	$ret = $global:GetModuleHandleW.Invoke($lpModuleNameUni)

	if ($lpModuleName) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpModuleNameUni) }

	return $ret
}
