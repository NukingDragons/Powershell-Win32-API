# Depends on BaseWin32Class.ps1
class STARTUPINFOA : BaseWin32Class
{
	[UInt32] $cb = $this.Size()
	[String] $lpReserved = ""
	[String] $lpDesktop = ""
	[String] $lpTitle = ""
	[UInt32] $dwX
	[UInt32] $dwY
	[UInt32] $dwXSize
	[UInt32] $dwYSize
	[UInt32] $dwXCountChars
	[UInt32] $dwYCountChars
	[UInt32] $dwFillAttribute
	[UInt32] $dwFlags
	[UInt16] $wShowWindow
	[UInt16] $cbReserved2
	[Byte[]] $lpReserved2 = $null
	[IntPtr] $hStdInput
	[IntPtr] $hStdOutput
	[IntPtr] $hStdError

	[UInt64] Size()
	{
		$Padding = 0
		if ([System.IntPtr]::Size -eq 8) { $Padding = 8 }
		return 40 + ([System.IntPtr]::Size * 7) + $Padding
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[IntPtr] $lpReservedAnsi = [IntPtr]::Zero
		[IntPtr] $lpDesktopAnsi = [IntPtr]::Zero
		[IntPtr] $lpTitleAnsi = [IntPtr]::Zero

		if ($this.lpReserved.Length -gt 0)
		{
			$lpReservedAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.lpReserved)
		}

		if ($this.lpDesktop.Length -gt 0)
		{
			$lpDesktopAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.lpDesktop)
		}

		if ($this.lpTitle.Length -gt 0)
		{
			$lpTitleAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.lpTitle)
		}

		[IntPtr[]] $Reserved = @([IntPtr]::Zero)

		# Even though I'm pretty sure cbReserved2 is the number of bytes of lpReserved2
		# I'm not going to enforce this, because there might be an exploit some day that abuses it
		# Anyone who wants to touch reserve values anyways ought to know what they are doing
		if ($this.lpReserved2)
		{
			$Reserved[0] = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($this.lpReserved2.Length)
			[System.Runtime.InteropServices.Marshal]::Copy($this.lpReserved2, 0, $Reserved[0], $this.lpReserved2.Length)
		}

		[UInt32[]] $CountBytes = @($this.cb)
		[IntPtr[]] $Strings = @($lpReservedAnsi, $lpDesktopAnsi, $lpTitleAnsi)
		[UInt32[]] $Data32 = @($this.dwX, $this.dwY, $this.dwXSize, $this.dwYSize, $this.dwXCountChars, $this.dwYCountChars, $this.dwFillAttribute, $this.dwFlags)
		[UInt16[]] $Data16 = @($this.wShowWindow, $this.cbReserved2)
		[IntPtr[]] $Stdio = @($this.hStdInput, $this.hStdOutput, $this.hStdError)

		[System.Runtime.InteropServices.Marshal]::Copy($CountBytes, 0, $Mem, $CountBytes.Length)
		$Offset = 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Strings, 0, $Mem.ToInt64() + $Offset, $Strings.Length)
		$Offset += ($Strings.Length * [System.IntPtr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem.ToInt64() + $Offset, $Data32.Length)
		$Offset += 32
		[System.Runtime.InteropServices.Marshal]::Copy($Data16, 0, $Mem.ToInt64() + $Offset, $Data16.Length)
		$Offset += 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Reserved, 0, $Mem.ToInt64() + $Offset, $Reserved.Length)
		$Offset += ($Reserved.Length * [System.IntPtr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Stdio, 0, $Mem.ToInt64() + $Offset, $Stdio.Length)

		return $Mem
	}

	[STARTUPINFOA] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $CountBytes = [UInt32[]]::new(1)
		[IntPtr[]] $Strings = [IntPtr[]]::new(3)
		[UInt32[]] $Data32 = [UInt32[]]::new(8)
		[UInt16[]] $Data16 = [UInt32[]]::new(2)
		[IntPtr[]] $Reserved = [IntPtr[]]::new(1)
		[IntPtr[]] $Stdio = [IntPtr[]]::new(3)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $CountBytes, 0, $CountBytes.Length)
		$Offset = 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Strings, 0, $Strings.Length)
		$Offset += ($Strings.Length * [System.Intptr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data32, 0, $Data32.Length)
		$Offset += 32
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data16, 0, $Data16.Length)
		$Offset += 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Reserved, 0, $Reserved.Length)
		$Offset += ($Reserved.Length * [System.IntPtr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Stdio, 0, $Stdio.Length)

		$this.cb = $CountBytes[0]
		$this.lpReserved = ""
		$this.lpDesktop = ""
		$this.lpTitle = ""
		$this.dwX = $Data32[0]
		$this.dwY = $Data32[1]
		$this.dwXSize = $Data32[2]
		$this.dwYSize = $Data32[3]
		$this.dwXCountChars = $Data32[4]
		$this.dwYCountChars = $Data32[5]
		$this.dwFillAttribute = $Data32[6]
		$this.dwFlags = $Data32[7]
		$this.wShowWindow = $Data16[0]
		$this.cbReserved2 = $Data16[1]
		$this.lpReserved2 = $null
		$this.hStdInput = $Stdio[0]
		$this.hStdOutput = $Stdio[1]
		$this.hStdError = $Stdio[2]

		if ($Strings[0] -ne [IntPtr]::Zero)
		{
			$this.lpReserved = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Strings[0])
		}

		if ($Strings[1] -ne [IntPtr]::Zero)
		{
			$this.lpDesktop = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Strings[1])
		}

		if ($Strings[2] -ne [IntPtr]::Zero)
		{
			$this.lpTitle = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Strings[2])
		}

		if ($Reserved[0] -ne [IntPtr]::Zero)
		{
			$this.lpReserved2 = [Byte[]]::new($this.cbReserved2)
			[System.Runtime.InteropServices.Marshal]::Copy($Reserved[0], $this.lpReserved2, 0, $this.lpReserved2.Length)
		}

		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[IntPtr[]] $Strings = [IntPtr[]]::new(3)
		[IntPtr[]] $Reserved = [IntPtr[]]::new(1)

		$Offset = 4
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Strings, 0, $Strings.Length)
		$Offset += 36 + ($Strings.Length * [System.IntPtr]::Size)
		if ([System.IntPtr]::Size -eq 8) { $Offset += 4 }
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Reserved, 0, $Reserved.Length)

		if ($Strings[0] -ne [IntPtr]::Zero) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Strings[0]) }
		if ($Strings[1] -ne [IntPtr]::Zero) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Strings[1]) }
		if ($Strings[2] -ne [IntPtr]::Zero) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Strings[2]) }
		if ($Reserved[0] -ne [IntPtr]::Zero) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Reserved[0]) }

		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
