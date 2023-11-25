# Depends on BaseWin32Union.ps1
# Depends on structures/S_un.ps1
class IN_ADDR : BaseWin32Union
{
	[S_un] $S_un = [S_un]::new()
	[UInt32] $s_addr = 0

	# Internal variables, for mimicking union behavior
	hidden [UInt32] $s_addr_internal = 0

	[UInt64] Size()
	{
		return $this.S_un.Size()
	}

    [IntPtr] ToUnmanaged()
    {
		if ($this.s_addr -ne $this.s_addr_internal)
		{
			$this.S_un.S_addr = $this.s_addr
		}

		$Mem = $this.S_un.ToUnmanaged()

		# Normalize with the internal variables
		$this.FromUnmanaged($Mem) | Out-Null

		return $Mem
    }

	[IN_ADDR] FromUnmanaged([IntPtr] $Unmanaged)
	{
		$this.S_un = ([S_un]::new()).FromUnmanaged($Unmanaged)
		$this.s_addr = $this.S_un.S_addr

		return $this
	}

	[IN_ADDR] FromBytes([Byte[]] $Bytes)
	{
		$this.S_un = $this.S_un.FromBytes($Bytes)
		$this.s_addr = $this.S_un.S_addr

		return $this
	}
}
