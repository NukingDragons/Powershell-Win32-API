# Depends on BaseWin32Union.ps1
# Depends on structures/S_un_b.ps1
# Depends on structures/S_un_w.ps1
class S_un : BaseWin32Union
{
	[S_un_b] $S_un_b = [S_un_b]::new()
	[S_un_w] $S_un_w = [S_un_w]::new()
	[UInt32] $S_addr = 0

	# Internal variables, for mimicking union behavior
	hidden [S_un_b] $S_un_b_internal = [S_un_b]::new()
	hidden [S_un_w] $S_un_w_internal = [S_un_w]::new()
	hidden [UInt32] $S_addr_internal = 0

	[UInt64] Size()
	{
		return 4
	}

    [IntPtr] ToUnmanaged()
    {
		[IntPtr] $Mem = [IntPtr]::Zero

		# Determine which source to use
		if ($this.S_un_b.Equals($this.S_un_b_internal) -ne $True)
		{
			$Mem = $this.S_un_b.ToUnmanaged()
		}
		elseif ($this.S_un_w.Equals($this.S_un_w_internal) -ne $True)
		{
			$Mem = $this.S_un_w.ToUnmanaged()
		}
		elseif ($this.S_addr -ne $this.S_addr_internal)
		{
			$Size = $this.Size()
			$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
			[Byte[]] $Raw = [Byte[]]::new($Size)
			[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

			[UInt32[]] $Data32 = @($this.S_addr)
			[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem, $Data32.Length)
		}
		# Everything in the union is equal, pick the fastest method here
		else
		{
			$Mem = $this.S_un_b.ToUnmanaged()
		}

		# Normalize with the internal variables
		$this.FromUnmanaged($Mem) | Out-Null

        return $Mem
    }

	[S_un] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $Data32 = [UInt32[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data32, 0, $Data32.Length)

		$this.S_un_b = ([S_un_b]::new()).FromUnmanaged($Unmanaged)
		$this.S_un_w = ([S_un_w]::new()).FromUnmanaged($Unmanaged)
		$this.S_addr = $Data32[0]

		$this.S_un_b_internal = ([S_un_b]::new()).FromUnmanaged($Unmanaged)
		$this.S_un_w_internal = ([S_un_w]::new()).FromUnmanaged($Unmanaged)
		$this.S_addr_internal = $Data32[0]

		return $this
	}
}
