# Depends on kernel32.dll/GetProcAddress.ps1
# Depends on kernel32.dll/LoadLibraryW.ps1
# Function for finding function addresses
function LoadFunction
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][String] $ModuleName,
		[Parameter(Position = 1, Mandatory = $True)][String] $FunctionName,
		[Parameter(Position = 2, Mandatory = $True)][Type[]] $FunctionParams,
		[Parameter(Position = 3)                   ][Type]   $FunctionRetType = [Void]
	)

	[IntPtr] $FuncPtr = [IntPtr]::Zero

	# If the GetProcAddress/LoadLibraryW functions have been created, use them instead
	if ($global:GetProcAddress -eq $null -or $global:LoadLibraryW -eq $null)
	{
		# Get all of the unsafe methods from the System assembly
		$UnsafeMethods = ([AppDomain]::CurrentDomain.GetAssemblies() | where { $_.GlobalAssemblyCache -And $_.Location.Split('\\')[-1].Equals('System.dll') }).GetType('Microsoft.Win32.UnsafeNativeMethods').GetMethods()

		# Fetch a GetModuleHandle function from the unsafe methods
		$tmp=@()
		$UnsafeMethods | ForEach { if($_.Name -eq "GetModuleHandle"){ $tmp += $_ } }
		$GetModuleHandle = $tmp[0]

		# Fetch a GetProcAddress function from the unsafe methods
		$tmp=@()
		$UnsafeMethods | ForEach { if($_.Name -eq "GetProcAddress"){ $tmp += $_ } }
		$GetProcAddress = $tmp[0]

		# Fetch the function requested
		$FuncPtr = $GetProcAddress.Invoke($null, @($GetModuleHandle.Invoke($null, @($ModuleName)), $FunctionName))
	}

	# If we don't have the function pointer, attempt to load it with with LoadLibraryW + GetProcAddress
	if ($FuncPtr -eq [IntPtr]::Zero)
	{
		$Handle = LoadLibraryW $ModuleName

		if ($Handle -eq $null)
		{
			throw 'Failed to find "' + $ModuleName + '"!'
		}

		$FuncPtr = GetProcAddress $Handle $FunctionName
	}

	if ($FuncPtr -eq $null)
	{
		throw 'Failed to find "' + $FunctionName + '" within "' + $ModuleName + '"!'
	}

	# Assembly type builder
	$TypeBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly((New-Object System.Reflection.AssemblyName('ReflectedDelegate')), [System.Reflection.Emit.AssemblyBuilderAccess]::Run).DefineDynamicModule('InMemoryModule', $false).DefineType('MyDelegateType', 'Class, Public, Sealed, AnsiClass, AutoClass', [System.MulticastDelegate])

	# Constructor builder for the type
	$ConstructorBuilder = $TypeBuilder.DefineConstructor('RTSpecialName, HideBySig, Public', [System.Reflection.CallingConventions]::Standard, $FunctionParams)
	$ConstructorBuilder.SetImplementationFlags('Runtime, Managed')

	# Method builder for the type
	$MethodBuilder = $TypeBuilder.DefineMethod('Invoke', 'Public, HideBySig, NewSlot, Virtual', $FunctionRetType, $FunctionParams)
	$MethodBuilder.SetImplementationFlags('Runtime, Managed')

	# Assign the type to the function pointer
	return [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer($FuncPtr, $TypeBuilder.CreateType())
}
