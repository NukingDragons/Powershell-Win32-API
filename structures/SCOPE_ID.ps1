# Depends on BaseWin32Union.ps1
class SCOPE_ID : BaseWin32Union
{
	[UInt32] $Zone = 0
	[UInt32] $Level = 0
	[UInt32] $Value = 0

	# Internal variables, for mimicking union behavior
	hidden [UInt32] $Zone_internal = 0
	hidden [UInt32] $Level_internal = 0
	hidden [UInt32] $Value_internal = 0

	[UInt64] Size()
	{
		return 4
	}

    [IntPtr] ToUnmanaged()
    {
		[UInt32[]] $Data32 = [UInt32[]]::new(1)
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		# Determine which source to use
		if ($this.Zone -ne $this.Zone_internal -or $this.Level -ne $this.Level_internal)
		{
			$Data32[0] = ($this.Level -shl 28) + $this.Zone
		}
		elseif ($this.Value -ne $this.Value_internal)
		{
			$Data32[0] = $this.Value
		}
		# Everything in the union is equal, pick the fastest method here
		else
		{
			$Data32[0] = $this.Value
		}

		[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem, $Data32.Length)

		# Normalize with the internal variables
		$this.FromUnmanaged($Mem) | Out-Null

        return $Mem
    }

	[SCOPE_ID] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $Data32 = [UInt32[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data32, 0, $Data32.Length)

		$this.Value = $Data32[0]
		$this.Level = ($Data32[0] -band 0xF0000000) -shr 28
		$this.Zone = $Data32[0] -band 0x0FFFFFFF

		$this.Value_internal = $this.Value
		$this.Level_internal = $this.Level
		$this.Zone_internal = $this.Zone

		return $this
	}
}
