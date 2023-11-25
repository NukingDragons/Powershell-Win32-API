# Depends on BaseWin32Class.ps1
# Depends on structures/SECURITY_DESCRIPTOR.ps1
class SECURITY_ATTRIBUTES : BaseWin32Class
{
	[UInt32] $nLength
	[SECURITY_DESCRIPTOR] $lpSecurityDescriptor = $null
	[Bool] $bInheritHandle

	[UInt64] Size()
	{
		return 8 + [System.IntPtr]::Size
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[IntPtr] $SecurityDescriptor = [IntPtr]::Zero
		if ($this.lpSecurityDescriptor) { $SecurityDescriptor = $this.lpSecurityDescriptor.ToUnmanaged() }

		[UInt32[]] $Data1 = @($this.nLength)
		[IntPtr[]] $Pointer = @($SecurityDescriptor)
		[UInt32[]] $Data2 = @($this.bInheritHandle)

		[System.Runtime.InteropServices.Marshal]::Copy($Data1, 0, $Mem, $Data1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Pointer, 0, $Mem.ToInt64() + 4, $Pointer.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data2, 0, $Mem.ToInt64() + 4 + ([System.IntPtr]::Size * $Pointer.Length), $Data2.Length)

		return $Mem
	}

	[SECURITY_ATTRIBUTES] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $Data1 = [UInt32[]]::new(1)
		[IntPtr[]] $Pointer = [IntPtr[]]::new(1)
		[UInt32[]] $Data2 = [UInt32[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data1, 0, $Data1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $Pointer, 0, $Pointer.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4 + ([System.IntPtr]::Size * $Pointer.Length), $Data2, 0, $Data2.Length)

		$this.nLength = $Data1[0]
		$this.bInheritHandle = $Data2[0]

		if ($Pointer[0] -ne [IntPtr]::Zero)
		{
			$this.lpSecurityDescriptor = ([SECURITY_DESCRIPTOR]::new()).FromUnmanaged($Pointer[0])
		}

		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[IntPtr[]] $Pointer = [IntPtr[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $Pointer, 0, $Pointer.Length)

		if ($Pointer[0] -ne [IntPtr]::Zero) { ([SECURITY_DESCRIPTOR]::new()).FreeUnmanaged($Pointer[0]) }

		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
