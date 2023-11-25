# Depends on BaseWin32Class.ps1
# Depends on structures/FLOWSPEC.ps1
# Depends on structures/WSABUF.ps1
class QOS : BaseWin32Class
{
	[FLOWSPEC] $SendingFlowspec
	[FLOWSPEC] $ReceivingFlowspec
	[WSABUF] $ProviderSpecific

	[UInt64] Size()
	{
		return $this.SendingFlowSpec.Size() + $this.ReceivingFlowspec.Size() + $this.ProviderSpecific.Size()
	}

    [IntPtr] ToUnmanaged()
    {
		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Byte[]] $Data8_1 = $this.SendingFlowspec.ToBytes()
		[Byte[]] $Data8_2 = $this.ReceivingFlowspec.ToBytes()
		[Byte[]] $Data8_3 = $this.ProviderSpecific.ToBytes()

		[System.Runtime.InteropServices.Marshal]::Copy($Data8_1, 0, $Mem, $Data8_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data8_2, 0, $Mem.ToInt64() + $Data8_1.Length, $Data8_2.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data8_3, 0, $Mem.ToInt64() + ($Data8_1.Length * 2), $Data8_3.Length)

        return $Mem
    }

	[QOS] FromUnmanaged([IntPtr] $Unmanaged)
	{
		$this.SendingFlowspec = ([FLOWSPEC]::new()).FromUnmanaged($Unmanaged)
		$this.ReceivingFlowspec = ([FLOWSPEC]::new()).FromUnmanaged($Unmanaged.ToInt64() + $this.SendingFlowspec.Size())
		$this.ProviderSpecific = ([WSABUF]::new()).FromUnmanaged($Unmanaged.ToInt64() + ($this.SendingFlowspec.Size() * 2))

		return $this
	}
}
