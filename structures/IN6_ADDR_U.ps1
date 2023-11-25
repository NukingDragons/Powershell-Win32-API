# Depends on BaseWin32Union.ps1
class IN6_ADDR_U : BaseWin32Union
{
	[Byte[]] $Byte = [Byte[]]::new(16)
	[UInt16[]] $Word = [UInt16[]]::new(8)

	# Internal variables, for mimicking union behavior
	hidden [Byte[]] $Byte_internal = [Byte[]]::new(16)
	hidden [UInt16[]] $Word_internal = [UInt16[]]::new(8)

	[UInt64] Size()
	{
		return 16
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		# Determine which source to use
		if ($this.Byte -ne $this.Byte_internal)
		{
			$Length = $this.Byte.Length
			if ($Length -gt $Size) { $Length = $Size }
			[System.Runtime.InteropServices.Marshal]::Copy($this.Byte, 0, $Mem, $Length)
		}
		elseif ($this.Word -ne $this.Word_internal)
		{
			$Length = $this.Word.Length * 2
			if ($Length -gt $Size) { $Length = $Size }
			[System.Runtime.InteropServices.Marshal]::Copy($this.Word, 0, $Mem, $Length)
		}
		# Everything in the union is equal, pick the fastest method here
		else
		{
			$Length = $this.Word.Length
			if ($Length -gt $Size) { $Length = $Size / 2 }
			[System.Runtime.InteropServices.Marshal]::Copy($this.Word, 0, $Mem, $Length)
		}

		# Normalize with the internal variables
		$this.FromUnmanaged($Mem) | Out-Null

		return $Mem
	}

	[IN6_ADDR_U] FromUnmanaged([IntPtr] $Unmanaged)
	{
		$this.Byte = [Byte[]]::new(16)
		$this.Word = [UInt16[]]::new(8)
		$this.Byte_internal = [Byte[]]::new(16)
		$this.Word_internal = [UInt16[]]::new(8)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $this.Byte, 0, $this.Byte.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $this.Word, 0, $this.Word.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $this.Byte_internal, 0, $this.Byte_internal.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $this.Word_internal, 0, $this.Word_internal.Length)

		return $this
	}
}
