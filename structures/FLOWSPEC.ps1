# Depends on BaseWin32Class.ps1
class FLOWSPEC : BaseWin32Class
{
	[UInt64] $TokenRate
	[UInt64] $TokenBucketSize
	[UInt64] $PeakBandwidth
	[UInt64] $Latency
	[UInt64] $DelayVariation
	[UInt32] $ServiceType
	[UInt64] $MaxSduSize
	[UInt64] $MinimumPolicedSize

	[UInt64] Size()
	{
		return 60
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[UInt64[]] $Data64_1 = @($this.TokenRate, $this.TokenBucketSize, $this.PeakBandwidth, $this.Latency, $this.DelayVariation)
		[UInt32[]] $Data32 = @($this.ServiceType)
		[UInt64[]] $Data64_2 = @($this.MaxSduSize, $this.MinimumPolicedSize)

		[System.Runtime.InteropServices.Marshal]::Copy($Data64_1, 0, $Mem, $Data64_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem.ToInt64() + $Data64_1.Length, $Data32.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data64_2, 0, $Mem.ToInt64() + $Data64_1.Length + $Data32.Length, $Data64_2.Length)

		return $Mem
	}

	[FLOWSPEC] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt64[]] $Data64_1 = [UInt64[]]::new(5)
		[UInt32[]] $Data32 = [UInt32[]]::new(1)
		[UInt64[]] $Data64_2 = [UInt64[]]::new(2)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data64_1, 0, $Data64_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 40, $Data32, 0, $Data32.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 44, $Data64_2, 0, $Data64_2.Length)

		$this.TokenRate = $Data64_1[0]
		$this.TokenBucketSize = $Data64_1[1]
		$this.PeakBandwidth = $Data64_1[2]
		$this.Latency = $Data64_1[3]
		$this.DelayVariation = $Data64_1[4]
		$this.ServiceType = $Data32[0]
		$this.MaxSduSize = $Data64_2[0]
		$this.MinimumPolicedSize = $Data64_2[1]

		return $this
	}
}
