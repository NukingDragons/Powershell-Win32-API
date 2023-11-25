# Depends on BaseWin32Class.ps1
class WSABUF : BaseWin32Class
{
	[UInt64] $len
	[String] $buf

	[UInt64] Size()
	{
		return $this.buf.Length + 8
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[UInt64[]] $Data64 = [UInt64[]]::new(1)

		if ($this.len -eq 0) { $this.len = $this.buf.Length }
		$Data64[0] = $this.len
		if ($Data64[0] -gt $this.buf.Length) { $Data64[0] = $this.buf.Length }

		[Byte[]] $String = [Byte[]]::new($Data64[0])
		[IntPtr] $StringMem = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.buf)
		[System.Runtime.InteropServices.Marshal]::Copy($StringMem, $String, 0, $StringMem.Length)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($StringMem)

		[System.Runtime.InteropServices.Marshal]::Copy($Data64, 0, $Mem, $Data64.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($String, 0, $Mem.ToInt64() + 8, $Data64[0])

		return $Mem
	}

	[WSABUF] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt64[]] $Data64 = [UInt64[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data64, 0, $Data64.Length)
		$this.buf = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($Unmanaged.ToInt64() + 8)
		$this.len = $Data64[0]

		return $this
	}
}
