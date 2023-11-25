# Depends on BaseWin32Class.ps1
class WSAPROTOCOLCHAIN : BaseWin32Class
{
	[Int32] $ChainLen
	[UInt32[]] $ChainEntries = [UInt32[]]::new(7)

	[UInt64] Size()
	{
		return 32
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Int32[]] $Data32 = @($this.ChainLen)

		$Length = $this.ChainEntries.Length
		if ($Length -gt 7) { $Length = 7 }

		[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem, $Data32.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($this.ChainEntries, 0, $Mem.ToInt64() + 4, $Length)

		return $Mem
	}

	[WSAPROTOCOLCHAIN] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Int32[]] $Data32 = [Int32[]]::new(1)
		$this.ChainEntries = [UInt32[]]::new(7)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data32, 0, $Data32.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $this.ChainEntries, 0, $this.ChainEntries.Length)

		$this.ChainLen = $Data32[0]

		return $this
	}
}
