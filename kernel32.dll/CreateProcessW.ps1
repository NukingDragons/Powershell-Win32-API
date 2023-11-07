# Depends on LoadFunction.ps1
# Depends on structures/STARTUPINFOW.ps1
# Depends on structures/PROCESS_INFORMATION.ps1
# Depends on structures/SECURITY_ATTRIBUTES.ps1
# Depends on structures/SECURITY_DESCRIPTOR.ps1
# Depends on structures/SID.ps1
# Depends on structures/SID_IDENTIFIER_AUTHORITY.ps1
# Depends on structures/ACL.ps1
function CreateProcessW
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
		[STARTUPINFOW] $lpStartupInfo,

        [Parameter(Position = 9, Mandatory = $True, ParameterSetName = "Both")]
        [Parameter(Position = 8, Mandatory = $True, ParameterSetName = "ApplicationName")]
        [Parameter(Position = 8, Mandatory = $True, ParameterSetName = "CommandLine")]
		[PROCESS_INFORMATION] $lpProcessInformation
    )

	$CreateProcessW = LoadFunction kernel32.dll CreateProcessW @([IntPtr], [IntPtr], [IntPtr], [IntPtr], [UInt32], [UInt32], [IntPtr], [IntPtr], [IntPtr], [IntPtr]) ([IntPtr])

	$lpApplicationNameUni = [IntPtr]::Zero
	$lpCommandLineUni = [IntPtr]::Zero
	$lpProcessAttributesMem = [IntPtr]::Zero
	$lpThreadAttributesMem = [IntPtr]::Zero
	$InheritHandles = 0
	$lpCurrentDirectoryUni = [IntPtr]::Zero
	$lpStartupInfoMem = $lpStartupInfo.ToUnmanaged()
	$lpProcessInformationMem = $lpProcessInformation.ToUnmanaged()

	if ($lpApplicationName) { $lpApplicationNameUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpApplicationName) }
	if ($lpCommandLine) { $lpCommandLineUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpCommandLine) }
	if ($lpProcessAttributes) { $lpProcessAttributesMem = $lpProcessAttributes.ToUnmanaged() }
	if ($lpThreadAttributes) { $lpThreadAttributesMem = $lpThreadAttributes.ToUnmanaged() }
	if ($bInheritHandles) { $InHeritHandles = 1 }
	if ($lpCurrentDirectory) { $lpCurrentDirectoryUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpCurrentDirectory) }

	$ret = $CreateProcessW.Invoke($lpApplicationNameUni, $lpCommandLineUni, $lpProcessAttributesMem, $lpThreadAttributesMem, $InheritHandles, $dwCreationFlags, $lpEnvironment, $lpCurrentDirectoryUni, $lpStartupInfoMem, $lpProcessInformationMem)

	if ($lpApplicationName) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpApplicationNameUni) }
	if ($lpProcessAttributes) { $lpProcessAttributes.FreeUnmanaged($lpProcessAttributesMem) }
	if ($lpThreadAttributes) { $lpThreadAttributes.FreeUnmanaged($lpThreadAttributesMem) }
	if ($lpCurrentDirectory) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpCurrentDirectoryUni) }

	$lpStartupInfo.FreeUnmanaged($lpStartupInfoMem)

	if ($lpCommandLine)
	{
		$lpCommandLine = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($lpCommandLineUni)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpCommandLineUni)
	}

	$lpProcessInformation.FromUnmanaged($lpProcessInformationMem) | Out-Null
	$lpProcessInformation.FreeUnmanaged($lpProcessInformationMem)

	return $ret
}