class SID_IDENTIFIER_AUTHORITY
{
    [Byte[]] $Value = [Byte[]]::new(6)

    [IntPtr] ToUnmanaged()
    {
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(6)
        [Byte[]] $Raw = [Byte[]]::new(6)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, 6)

        $Length = $this.Value.Length
        if ($Length -gt 6) { $Length = 6 }

        [System.Runtime.InteropServices.Marshal]::Copy($this.Value, 0, $Mem, $Length)

        return $Mem
    }

	[SID_IDENTIFIER_AUTHORITY] FromUnmanaged([IntPtr] $Unmanaged)
	{
		$this.Value = [Byte[]]::new(6)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $this.Value, 0, $this.Value.Length)

        return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
