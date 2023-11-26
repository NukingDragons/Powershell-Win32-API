# Depends on BaseWin32Class.ps1
# Depends on structures/SECURITY_DESCRIPTOR.ps1
class SECURITY_ATTRIBUTES : BaseWin32Class
{
	[UInt32] $nLength
	[SECURITY_DESCRIPTOR] $lpSecurityDescriptor = $null
	[Bool] $bInheritHandle

	[UInt64] Size()
	{
		$Padding = 0
		if ([System.IntPtr]::Size -eq 8) { $Padding = 4 }
		return 8 + [System.IntPtr]::Size + $Padding
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
		$Offset = 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Pointer, 0, $Mem.ToInt64() + $Offset, $Pointer.Length)
		$Offset += ($Pointer.Length * [System.IntPtr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Data2, 0, $Mem.ToInt64() + $Offset, $Data2.Length)

		return $Mem
	}

	[SECURITY_ATTRIBUTES] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $Data1 = [UInt32[]]::new(1)
		[IntPtr[]] $Pointer = [IntPtr[]]::new(1)
		[UInt32[]] $Data2 = [UInt32[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data1, 0, $Data1.Length)
		$Offset = 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Pointer, 0, $Pointer.Length)
		$Offset += ($Pointer.Length * [System.IntPtr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data2, 0, $Data2.Length)

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

		$Offset = 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Pointer, 0, $Pointer.Length)

		if ($Pointer[0] -ne [IntPtr]::Zero) { ([SECURITY_DESCRIPTOR]::new()).FreeUnmanaged($Pointer[0]) }

		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
