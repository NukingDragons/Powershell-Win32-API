# Depends on BaseWin32Class.ps1
class SID_IDENTIFIER_AUTHORITY : BaseWin32Class
{
	[Byte[]] $Value = [Byte[]]::new(6)

	[UInt64] Size()
	{
		return 6
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		$Length = $this.Value.Length
		if ($Length -gt $Size) { $Length = $Size }

		[System.Runtime.InteropServices.Marshal]::Copy($this.Value, 0, $Mem, $Length)

		return $Mem
	}

	[SID_IDENTIFIER_AUTHORITY] FromUnmanaged([IntPtr] $Unmanaged)
	{
		$Size = $this.Size()
		$this.Value = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $this.Value, 0, $this.Value.Length)

		return $this
	}
}
