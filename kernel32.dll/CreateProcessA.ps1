# Depends on LoadFunction.ps1
# Depends on structures/STARTUPINFOA.ps1
# Depends on structures/PROCESS_INFORMATION.ps1
# Depends on structures/SECURITY_ATTRIBUTES.ps1
function CreateProcessA
{
	[CmdletBinding(DefaultParameterSetName="ApplicationName")]
    param(
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = "ApplicationName")]
        [Parameter(                                 ParameterSetName = "CommandLine")]
		[String] $lpApplicationName = "",

        [Parameter(Position = 1, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(                                 ParameterSetName = "ApplicationName")]
        [Parameter(Position = 0, Mandatory = $True, ParameterSetName = "CommandLine")]
		[ref][String] $lpCommandLine,

        [Parameter(Position = 2                   , ParameterSetName = "Both")]
        [Parameter(Position = 1                   , ParameterSetName = "ApplicationName")]
        [Parameter(Position = 1                   , ParameterSetName = "CommandLine")]
		[SECURITY_ATTRIBUTES] $lpProcessAttributes = $null,

        [Parameter(Position = 3                   , ParameterSetName = "Both")]
        [Parameter(Position = 2                   , ParameterSetName = "ApplicationName")]
        [Parameter(Position = 2                   , ParameterSetName = "CommandLine")]
		[SECURITY_ATTRIBUTES] $lpThreadAttributes = $null,

        [Parameter(Position = 4, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(Position = 3, Mandatory = $True, ParameterSetName = "ApplicationName")]
        [Parameter(Position = 3, Mandatory = $True, ParameterSetName = "CommandLine")]
		[Bool] $bInheritHandles,

        [Parameter(Position = 5, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(Position = 4, Mandatory = $True, ParameterSetName = "ApplicationName")]
        [Parameter(Position = 4, Mandatory = $True, ParameterSetName = "CommandLine")]
		[UInt32] $dwCreationFlags,

        [Parameter(Position = 6                   , ParameterSetName = "Both")]
        [Parameter(Position = 5                   , ParameterSetName = "ApplicationName")]
        [Parameter(Position = 5                   , ParameterSetName = "CommandLine")]
		[IntPtr] $lpEnvironment = [IntPtr]::Zero,

        [Parameter(Position = 7                   , ParameterSetName = "Both")]
        [Parameter(Position = 6                   , ParameterSetName = "ApplicationName")]
        [Parameter(Position = 6                   , ParameterSetName = "CommandLine")]
		[String] $lpCurrentDirectory = (pwd).Path,

        [Parameter(Position = 8, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(Position = 7, Mandatory = $True, ParameterSetName = "ApplicationName")]
        [Parameter(Position = 7, Mandatory = $True, ParameterSetName = "CommandLine")]
		[STARTUPINFOA] $lpStartupInfo,

        [Parameter(Position = 9, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(Position = 8, Mandatory = $True, ParameterSetName = "ApplicationName")]
        [Parameter(Position = 8, Mandatory = $True, ParameterSetName = "CommandLine")]
		[PROCESS_INFORMATION] $lpProcessInformation
    )

	if ($global:CreateProcessA -eq $null)
	{
		$global:CreateProcessA = LoadFunction kernel32.dll CreateProcessA @([IntPtr], [IntPtr], [IntPtr], [IntPtr], [UInt32], [UInt32], [IntPtr], [IntPtr], [IntPtr], [IntPtr]) ([IntPtr])
	}

	$lpApplicationNameAnsi = [IntPtr]::Zero
	$lpCommandLineAnsi = [IntPtr]::Zero
	$lpProcessAttributesMem = [IntPtr]::Zero
	$lpThreadAttributesMem = [IntPtr]::Zero
	$InheritHandles = 0
	$lpCurrentDirectoryAnsi = [IntPtr]::Zero
	$lpStartupInfoMem = $lpStartupInfo.ToUnmanaged()
	$lpProcessInformationMem = $lpProcessInformation.ToUnmanaged()

	if ($lpApplicationName) { $lpApplicationNameAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpApplicationName) }
	if ($lpCommandLine) { $lpCommandLineAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpCommandLine) }
	if ($lpProcessAttributes) { $lpProcessAttributesMem = $lpProcessAttributes.ToUnmanaged() }
	if ($lpThreadAttributes) { $lpThreadAttributesMem = $lpThreadAttributes.ToUnmanaged() }
	if ($bInheritHandles) { $InHeritHandles = 1 }
	if ($lpCurrentDirectory) { $lpCurrentDirectoryAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($lpCurrentDirectory) }

	$ret = $global:CreateProcessA.Invoke($lpApplicationNameAnsi, $lpCommandLineAnsi, $lpProcessAttributesMem, $lpThreadAttributesMem, $InheritHandles, $dwCreationFlags, $lpEnvironment, $lpCurrentDirectoryAnsi, $lpStartupInfoMem, $lpProcessInformationMem)

	if ($lpApplicationName) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpApplicationNameAnsi) }
	if ($lpProcessAttributes) { $lpProcessAttributes.FreeUnmanaged($lpProcessAttributesMem) }
	if ($lpThreadAttributes) { $lpThreadAttributes.FreeUnmanaged($lpThreadAttributesMem) }
	if ($lpCurrentDirectory) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpCurrentDirectoryAnsi) }

	$lpStartupInfo.FreeUnmanaged($lpStartupInfoMem)

	if ($lpCommandLine)
	{
		$lpCommandLine = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($lpCommandLineAnsi)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpCommandLineAnsi)
	}

	$lpProcessInformation.FromUnmanaged($lpProcessInformationMem) | Out-Null
	$lpProcessInformation.FreeUnmanaged($lpProcessInformationMem)

	return $ret
}
