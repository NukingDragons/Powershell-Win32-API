# Depends on BaseWin32Class.ps1
# Depends on structures/SID_IDENTIFIER_AUTHORITY.ps1
class SID : BaseWin32Class
{
    [Byte] $Revision = 0
	[Byte] $SubAuthorityCount = 0
	[SID_IDENTIFIER_AUTHORITY] $IdentifierAuthority = [SID_IDENTIFIER_AUTHORITY]::new()
	[UInt32[]] $SubAuthority = @()

	[UInt64] Size()
	{
		return 2 + $this.IdentifierAuthority.Size() + ($this.SubAuthority.Length * 4)
	}

    [IntPtr] ToUnmanaged()
    {
		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

        $Raw = @($this.Revision, $this.SubAuthorityCount)
		[Byte[]] $IDAuth = $this.IdentifierAuthority.ToBytes()
		[UInt64] $IDAuthSize = $this.IdentifierAuthority.Size()

        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, 2)
        [System.Runtime.InteropServices.Marshal]::Copy($IDAuth, 0, $Mem.ToInt64() + 2, $IDAuthSize)
        [System.Runtime.InteropServices.Marshal]::Copy($this.SubAuthority, 0, $Mem.ToInt64() + $IDAuthSize + 2, $this.SubAuthority.Length)

        return $Mem
    }

	[SID] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Byte[]] $Raw = [Byte[]]::new(2)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Raw, 0, 2)

		$this.Revision = $Raw[0]
		$this.SubAuthorityCount = $Raw[1]
		$this.IdentifierAuthority = ([SID_IDENTIFIER_AUTHORITY]::new()).FromUnmanaged($Unmanaged.ToInt64() + 2)
		$this.SubAuthority = [UInt32[]]::new($this.SubAuthorityCount)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 2 + $this.IdentifierAuthority.Size(), $this.SubAuthority, 0, $this.SubAuthorityCount)
		return $this
	}
}
