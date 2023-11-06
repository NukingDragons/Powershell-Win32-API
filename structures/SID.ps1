# Depends on structures/SID_IDENTIFIER_AUTHORITY.ps1
class SID
{
    [Byte] $Revision = 0
	[Byte] $SubAuthorityCount = 0
	[SID_IDENTIFIER_AUTHORITY] $IdentifierAuthority = [SID_IDENTIFIER_AUTHORITY]::new()
	[UInt32[]] $SubAuthority = @()

    [IntPtr] ToUnmanaged()
    {
		$Size = 8 + ($this.SubAuthority.Length * 4)
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

        $Raw = @($this.Revision, $this.SubAuthorityCount)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, 2)
        [System.Runtime.InteropServices.Marshal]::Copy($this.IdentifierAuthority.Value, 0, $Mem.ToInt64() + 2, 6)
        [System.Runtime.InteropServices.Marshal]::Copy($this.SubAuthority, 0, $Mem.ToInt64() + 8, $this.SubAuthority.Length)

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

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 8, $this.SubAuthority, 0, $this.SubAuthorityCount)
		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
