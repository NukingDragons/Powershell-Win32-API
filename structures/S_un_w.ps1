# Depends on BaseWin32Class.ps1
class S_un_w : BaseWin32Class
{
	[UInt16] $s_w1
	[UInt16] $s_w2

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

		[UInt16[]] $Data16 = @($this.s_w1, $this.s_w2)

		[System.Runtime.InteropServices.Marshal]::Copy($Data16, 0, $Mem, $Data16.Length)

        return $Mem
    }

	[S_un_w] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt16[]] $Data16 = [Byte[]]::new(2)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data16, 0, $Data16.Length)

		$this.s_w1 = $Data16[0]
		$this.s_w2 = $Data16[1]

		return $this
	}
}
