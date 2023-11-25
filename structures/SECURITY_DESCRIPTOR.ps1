# Depends on BaseWin32Class.ps1
# Depends on structures/SID.ps1
# Depends on structures/ACL.ps1
class SECURITY_DESCRIPTOR : BaseWin32Class
{
	[Byte] $Revision
	[Byte] $Sbz1
	[UInt16] $Control
	[SID] $Owner = $null
	[SID] $Group = $null
	[ACL] $Sacl = $null
	[ACL] $Dacl = $null

	[UInt64] Size()
	{
		return 4 + ([System.IntPtr]::Size * 4)
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Byte[]] $Data8 = @($this.Revision, $this.Sbz1)
		[UInt16[]] $Data16 = @($this.Control)
		[IntPtr[]] $Pointers = @([IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero, [IntPtr]::Zero)

		if ($this.Owner) { $Pointers[0] = $this.Owner.ToUnmanaged() }
		if ($this.Group) { $Pointers[1] = $this.Group.ToUnmanaged() }
		if ($this.Sacl) { $Pointers[2] = $this.Sacl.ToUnmanaged() }
		if ($this.Dacl) { $Pointers[3] = $this.Dacl.ToUnmanaged() }

		[System.Runtime.InteropServices.Marshal]::Copy($Data8, 0, $Mem, $Data8.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data16, 0, $Mem.ToInt64() + 2, $Data16.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Pointers, 0, $Mem.ToInt64() + 4, $Pointers.Length)

		return $Mem
	}

	[SECURITY_DESCRIPTOR] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Byte[]] $Data8 = [Byte[]]::new(2)
		[UInt16[]] $Data16 = [UInt16[]]::new(1)
		[IntPtr[]] $Pointers = [IntPtr[]]::new(4)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data8, 0, $Data8.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 2, $Data16, 0, $Data16.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $Pointers, 0, $Pointers.Length)

		$this.Revision = $Data8[0]
		$this.Sbz1 = $Data8[1]
		$this.Control = $Data16[0]

		if ($Pointers[0] -ne [IntPtr]::Zero) { $this.Owner = ([SID]::new()).FromUnmanaged($Pointers[0]) }
		if ($Pointers[1] -ne [IntPtr]::Zero) { $this.Group = ([SID]::new()).FromUnmanaged($Pointers[1]) }
		if ($Pointers[2] -ne [IntPtr]::Zero) { $this.Sacl = ([ACL]::new()).FromUnmanaged($Pointers[2]) }
		if ($Pointers[3] -ne [IntPtr]::Zero) { $this.Dacl = ([ACL]::new()).FromUnmanaged($Pointers[3]) }

		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[IntPtr[]] $Pointers = [IntPtr[]]::new(4)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $Pointers, 0, $Pointers.Length)

		if ($Pointers[0] -ne [IntPtr]::Zero) { ([SID]::new()).FreeUnmanaged($Pointers[0]) }
		if ($Pointers[1] -ne [IntPtr]::Zero) { ([SID]::new()).FreeUnmanaged($Pointers[1]) }
		if ($Pointers[2] -ne [IntPtr]::Zero) { ([ACL]::new()).FreeUnmanaged($Pointers[2]) }
		if ($Pointers[3] -ne [IntPtr]::Zero) { ([ACL]::new()).FreeUnmanaged($Pointers[3]) }

		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
