# Depends on BaseWin32Class.ps1
class S_un_b : BaseWin32Class
{
	[Byte] $s_b1
	[Byte] $s_b2
	[Byte] $s_b3
	[Byte] $s_b4

	[UInt64] Size()
	{
		return 4
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Byte[]] $Data8 = @($this.s_b1, $this.s_b2, $this.s_b3, $this.s_b4)

		[System.Runtime.InteropServices.Marshal]::Copy($Data8, 0, $Mem, $Data8.Length)

		return $Mem
	}

	[S_un_b] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Byte[]] $Data8 = [Byte[]]::new(4)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data8, 0, $Data8.Length)

		$this.s_b1 = $Data8[0]
		$this.s_b2 = $Data8[1]
		$this.s_b3 = $Data8[2]
		$this.s_b4 = $Data8[3]

		return $this
	}
}
