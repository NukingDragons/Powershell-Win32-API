# Depends on BaseWin32Class.ps1
class ACL : BaseWin32Class
{
	[Byte] $AclRevision
	[Byte] $Sbz1
	[UInt16] $AclSize
	[UInt16] $AceCount
	[UInt16] $Sbz2

	[UInt64] Size()
	{
		return 8
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Byte[]] $Data8 = @($this.AclRevision, $this.Sbz1)
		[UInt16[]] $Data16 = @($this.AclSize, $this.AceCount, $this.Sbz2)

		[System.Runtime.InteropServices.Marshal]::Copy($Data8, 0, $Mem, $Data8.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data16, 0, $Mem.ToInt64() + 2, $Data16.Length)

		return $Mem
	}

	[ACL] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Byte[]] $Data8 = [Byte[]]::new(2)
		[UInt16[]] $Data16 = [UInt16[]]::new(3)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data8, 0, $Data8.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 2, $Data16, 0, $Data16.Length)

		$this.AclRevision = $Data8[0]
		$this.Sbz1 = $Data8[1]
		$this.AclSize = $Data16[0]
		$this.AceCount = $Data16[1]
		$this.Sbz2 = $Data16[2]

		return $this
	}
}
