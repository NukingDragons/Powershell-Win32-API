# Depends on BaseWin32Class.ps1
class STARTUPINFOA : BaseWin32Class
{
	[UInt32] $cb = $this.Size()
	[String] $lpDesktop
	[String] $lpTitle
	[UInt32] $dwX
	[UInt32] $dwY
	[UInt32] $dwXSize
	[UInt32] $dwYSize
	[UInt32] $dwXCountChars
	[UInt32] $dwYCountChars
	[UInt32] $dwFillAttribute
	[UInt32] $dwFlags
	[UInt16] $wShowWindow
	[IntPtr] $hStdInput
	[IntPtr] $hStdOutput
	[IntPtr] $hStdError

	[UInt64] Size()
	{
		return 40 + ([System.IntPtr]::Size * 7)
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[UInt32[]] $CountBytes = @($this.cb)
		[IntPtr[]] $Strings = @([System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.lpDesktop), [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.lpTitle))
		[UInt32[]] $Data32 = @($this.dwX, $this.dwY, $this.dwXSize, $this.dwYSize, $this.dwXCountChars, $this.dwYCountChars, $this.dwFillAttribute, $this.dwFlags)
		[UInt16[]] $Data16 = @($this.wShowWindow)
		[IntPtr[]] $Stdio = @($this.hStdInput, $this.hStdOutput, $this.hStdError)

		[System.Runtime.InteropServices.Marshal]::Copy($CountBytes, 0, $Mem, $CountBytes.Length)
		$Offset = 8
		[System.Runtime.InteropServices.Marshal]::Copy($Strings, 0, $Mem.ToInt64() + $Offset, $Strings.Length)
		$Offset += ($Strings.Length * [System.Intptr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem.ToInt64() + $Offset, $Data32.Length)
		$Offset += 32
		[System.Runtime.InteropServices.Marshal]::Copy($Data16, 0, $Mem.ToInt64() + $Offset, $Data16.Length)
		$Offset += 2
		[System.Runtime.InteropServices.Marshal]::Copy($Stdio, 0, $Mem.ToInt64() + $Offset, $Stdio.Length)

		return $Mem
	}

	[STARTUPINFOA] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $CountBytes = [UInt32[]]::new(1)
		[IntPtr[]] $Strings = [IntPtr[]]::new(2)
		[UInt32[]] $Data32 = [UInt32[]]::new(8)
		[UInt16[]] $Data16 = [UInt32[]]::new(1)
		[IntPtr[]] $Stdio = [IntPtr[]]::new(3)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $CountBytes, 0, $CountBytes.Length)
		$Offset = 8
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Strings, 0, $Strings.Length)
		$Offset += ($Strings.Length * [System.Intptr]::Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data32, 0, $Data32.Length)
		$Offset += 32
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data16, 0, $Data16.Length)
		$Offset += 2
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Stdio, 0, $Stdio.Length)

		$this.cb = $CountBytes[0]
		$this.lpDesktop = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Strings[0])
		$this.lpTitle = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Strings[0])
		$this.dwX = $Data32[0]
		$this.dwY = $Data32[1]
		$this.dwXSize = $Data32[2]
		$this.dwYSize = $Data32[3]
		$this.dwXCountChars = $Data32[4]
		$this.dwYCountChars = $Data32[5]
		$this.dwFillAttribute = $Data32[6]
		$this.dwFlags = $Data32[7]
		$this.wShowWindow = $Data16[0]
		$this.hStdInput = $Stdio[0]
		$this.hStdOutput = $Stdio[1]
		$this.hStdError = $Stdio[2]

		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[IntPtr[]] $Strings = [IntPtr[]]::new(2)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 8, $Strings, 0, $Strings.Length)

		if ($Strings[0]) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Strings[0]) }
		if ($Strings[1]) { [System.Runtime.InteropServices.Marshal]::FreeHGlobal($Strings[1]) }

		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
