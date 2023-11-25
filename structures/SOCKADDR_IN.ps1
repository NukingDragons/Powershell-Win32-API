# Depends on BaseWin32Class.ps1
# Depends on structures/IN_ADDR.ps1
class SOCKADDR_IN : BaseWin32Class
{
	[Int16] $sin_family
	[UInt16] $sin_port
	[IN_ADDR] $sin_addr = [IN_ADDR]::new()
	[Byte[]] $sin_zero = [Byte[]]::new(8)

	[UInt64] Size()
	{
		return 12 + $this.sin_addr.Size()
	}

    [IntPtr] ToUnmanaged()
    {
		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Int16[]] $Data16_1 = @($this.sin_family)
		[UInt16[]] $Data16_2 = @($this.sin_port)
		[Byte[]] $Addr = $this.sin_addr.ToBytes()

        $Length = $this.sin_zero.Length
        if ($Length -gt $Size) { $Length = $Size }

		[System.Runtime.InteropServices.Marshal]::Copy($Data16_1, 0, $Mem, $Data16_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data16_2, 0, $Mem.ToInt64() + 2, $Data16_2.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Addr, 0, $Mem.ToInt64() + 4, $Addr.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($this.sin_zero, 0, $Mem.ToInt64() + 4 + $Addr.Length, $Length)

        return $Mem
    }

	[SOCKADDR_IN] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Int16[]] $Data16_1 = [Int16[]]::new(1)
		[UInt16[]] $Data16_2 = [UInt16[]]::new(1)
		$this.sin_zero = [Byte[]]::new(8)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data16_1, 0, $Data16_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 2, $Data16_2, 0, $Data16_2.Length)
		$this.sin_addr = ([IN_ADDR]::new()).FromUnmanaged($Unmanaged.ToInt64() + 4)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4 + $this.sin_addr.Size(), $this.sin_zero, 0, $this.sin_zero.Length)

		$this.sin_family = $Data16_1[0]
		$this.sin_port = $Data16_2[0]

		return $this
	}
}
