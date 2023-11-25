# Depends on BaseWin32Class.ps1
class GUID : BaseWin32Class
{
	[UInt64] $Data1
	[UInt16] $Data2
	[UInt16] $Data3
	[Byte[]] $Data4 = [Byte[]]::new(8)

	[UInt64] Size()
	{
		return 20
	}

    [IntPtr] ToUnmanaged()
    {
		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[UInt64[]] $Data64 = @($this.Data1)
		[UInt16[]] $Data16 = @($this.Data2, $this.Data3)

        $Length = $this.Data4.Length
        if ($Length -gt 8) { $Length = 8 }

		[System.Runtime.InteropServices.Marshal]::Copy($Data64, 0, $Mem, $Data64.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data16, 0, $Mem.ToInt64() + 8, $Data16.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($this.Data4, 0, $Mem.ToInt64() + 12, $Length)

        return $Mem
    }

	[GUID] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt64[]] $Data64 = [UInt64[]]::new(1)
		[UInt16[]] $Data16 = [UInt16[]]::new(2)
		$this.Data4 = [Byte[]]::new(8)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data64, 0, $Data64.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 8, $Data16, 0, $Data16.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 12, $this.Data4, 0, $this.Data4.Length)

		$this.Data1 = $Data64[0]
		$this.Data2 = $Data16[0]
		$this.Data3 = $Data16[1]

		return $this
	}
}
