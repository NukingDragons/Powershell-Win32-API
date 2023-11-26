# Depends on LoadFunction.ps1
# Depends on structures/STARTUPINFOW.ps1
# Depends on structures/PROCESS_INFORMATION.ps1
# Depends on structures/SECURITY_ATTRIBUTES.ps1
# Depends on enums/PROCESS_CREATION_FLAGS.ps1
function CreateProcessW
{
    [CmdletBinding(DefaultParameterSetName="ApplicationName")]
	param(
		[Parameter(Position = 0, Mandatory = $True, ParameterSetName = "Both")]
		[Parameter(Position = 0, Mandatory = $True, ParameterSetName = "ApplicationName")]
		[String] $lpApplicationName = "",

		[Parameter(Position = 1, Mandatory = $True, ParameterSetName = "Both")]
		[Parameter(Position = 0, Mandatory = $True, ParameterSetName = "CommandLine")]
		[ValidateScript({
			if($_.Value.GetType().Name -eq "String")
			{
				return $true
			}
			else
			{
				throw "Expected a String by reference"
			}
			})]
		[ref] $lpCommandLine,

		[Parameter(Position = 2,                    ParameterSetName = "Both")]
		[Parameter(Position = 1,                    ParameterSetName = "ApplicationName")]
		[Parameter(Position = 1,                    ParameterSetName = "CommandLine")]
		[SECURITY_ATTRIBUTES] $lpProcessAttributes = $null,

		[Parameter(Position = 3,                    ParameterSetName = "Both")]
		[Parameter(Position = 2,                    ParameterSetName = "ApplicationName")]
		[Parameter(Position = 2,                    ParameterSetName = "CommandLine")]
		[SECURITY_ATTRIBUTES] $lpThreadAttributes = $null,

		[Parameter(Position = 4, Mandatory = $True, ParameterSetName = "Both")]
		[Parameter(Position = 3, Mandatory = $True, ParameterSetName = "ApplicationName")]
		[Parameter(Position = 3, Mandatory = $True, ParameterSetName = "CommandLine")]
		[Bool] $bInheritHandles,

		[Parameter(Position = 5, Mandatory = $True, ParameterSetName = "Both")]
		[Parameter(Position = 4, Mandatory = $True, ParameterSetName = "ApplicationName")]
		[Parameter(Position = 4, Mandatory = $True, ParameterSetName = "CommandLine")]
		[PROCESS_CREATION_FLAGS] $dwCreationFlags,

		[Parameter(Position = 6,                    ParameterSetName = "Both")]
		[Parameter(Position = 5,                    ParameterSetName = "ApplicationName")]
		[Parameter(Position = 5,                    ParameterSetName = "CommandLine")]
		[IntPtr] $lpEnvironment = [IntPtr]::Zero,

		[Parameter(Position = 7,                    ParameterSetName = "Both")]
		[Parameter(Position = 6,                    ParameterSetName = "ApplicationName")]
		[Parameter(Position = 6,                    ParameterSetName = "CommandLine")]
		[String] $lpCurrentDirectory = "",

		[Parameter(Position = 8, Mandatory = $True, ParameterSetName = "Both")]
		[Parameter(Position = 7, Mandatory = $True, ParameterSetName = "ApplicationName")]
		[Parameter(Position = 7, Mandatory = $True, ParameterSetName = "CommandLine")]
		[STARTUPINFOA] $lpStartupInfo,

		[Parameter(Position = 9, Mandatory = $True, ParameterSetName = "Both")]
		[Parameter(Position = 8, Mandatory = $True, ParameterSetName = "ApplicationName")]
		[Parameter(Position = 8, Mandatory = $True, ParameterSetName = "CommandLine")]
		[PROCESS_INFORMATION] $lpProcessInformation
	)

	if ($global:CreateProcessW -eq $null)
	{
		$global:CreateProcessW = LoadFunction kernel32.dll CreateProcessW @([IntPtr], [IntPtr], [IntPtr], [IntPtr], [UInt32], [UInt32], [IntPtr], [IntPtr], [IntPtr], [IntPtr]) ([IntPtr])
	}

	$lpApplicationNameUni = [IntPtr]::Zero
	$lpCommandLineUni = [IntPtr]::Zero
	$lpProcessAttributesMem = [IntPtr]::Zero
	$lpThreadAttributesMem = [IntPtr]::Zero
	$InheritHandles = 0
	$lpCurrentDirectoryUni = [IntPtr]::Zero
	$lpStartupInfoMem = $lpStartupInfo.ToUnmanaged()
	$lpProcessInformationMem = $lpProcessInformation.ToUnmanaged()

	if ($lpApplicationName.Length -gt 0) { $lpApplicationNameUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpApplicationName) }
	if ($lpCommandLine.Value.Length -gt 0) { $lpCommandLineUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpCommandLine.Value) }
	if ($lpProcessAttributes) { $lpProcessAttributesMem = $lpProcessAttributes.ToUnmanaged() }
	if ($lpThreadAttributes) { $lpThreadAttributesMem = $lpThreadAttributes.ToUnmanaged() }
	if ($bInheritHandles -eq $True) { $InheritHandles = 1 }
	if ($lpCurrentDirectory.Length -gt 0) { $lpCurrentDirectoryUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($lpCurrentDirectory) }

	$ret = $global:CreateProcessW.Invoke($lpApplicationNameUni, $lpCommandLineUni, $lpProcessAttributesMem, $lpThreadAttributesMem, $InheritHandles, ([UInt32]$dwCreationFlags), $lpEnvironment, $lpCurrentDirectoryUni, $lpStartupInfoMem, $lpProcessInformationMem)

	if ($lpApplicationName) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpApplicationNameUni) }
	if ($lpProcessAttributes) { $lpProcessAttributes.FreeUnmanaged($lpProcessAttributesMem) }
	if ($lpThreadAttributes) { $lpThreadAttributes.FreeUnmanaged($lpThreadAttributesMem) }
	if ($lpCurrentDirectory) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpCurrentDirectoryUni) }

	$lpStartupInfo.FreeUnmanaged($lpStartupInfoMem)

	if ($lpCommandLine)
	{
		$lpCommandLine.Value = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($lpCommandLineUni)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpCommandLineUni)
	}

	$lpProcessInformation.FromUnmanaged($lpProcessInformationMem) | Out-Null
	$lpProcessInformation.FreeUnmanaged($lpProcessInformationMem)

	return $ret
}
