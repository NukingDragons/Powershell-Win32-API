# Depends on BaseWin32Class.ps1
# Depends on structures/IN6_ADDR.ps1
# Depends on structures/SCOPE_ID.ps1
class SOCKADDR_IN6 : BaseWin32Union
{
	[Int16] $sin6_family
	[UInt16] $sin6_port
	[UInt32] $sin6_flowinfo
	[IN6_ADDR] $sin6_addr = [IN6_ADDR]::new()

	# Nameless union
	[UInt32] $sin6_scope_id = 0
	[SCOPE_ID] $sin6_scope_struct = [SCOPE_ID]::new()

	# Internal variables, for mimicking union behavior
	hidden [UInt32] $sin6_scope_id_internal = 0
	hidden [SCOPE_ID] $sin6_scope_struct_internal = [SCOPE_ID]::new()

	[UInt64] Size()
	{
		return 12 + $this.sin6_addr.Size()
	}

	[IntPtr] ToUnmanaged()
	{
		$Size = $this.Size()
		$Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[Byte[]] $Raw = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[Int16[]] $Data16_1 = @($this.sin6_family)
		[UInt16[]] $Data16_2 = @($this.sin6_port)
		[UInt32[]] $Data32 = @($this.sin6_flowinfo)
		[Byte[]] $Addr = $this.sin6_addr.ToBytes()
		[Byte[]] $sin6_scope = [Byte[]]::new(4)

		# Determine which source to use
		if ($this.sin6_scope_struct.Equals($this.sin6_scope_struct_internal) -ne $True)
		{
			$sin6_scope = $this.sin6_scope_struct.ToBytes()
		}
		elseif ($this.sin6_scope_id -ne $this.sin6_scope_id_internal)
		{
			$Size2 = 4
			$Mem2 = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size2)
			[Byte[]] $Raw = [Byte[]]::new($Size2)
			[System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem2, $Size2)

			[UInt32[]] $Data32 = @($this.sin6_scope_id)

			[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem2, $Data32.Length)
			[System.Runtime.InteropServices.Marshal]::Copy($Mem2, $sin6_scope, 0, $sin6_scope.Length)
			[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Mem2)
		}
		# Everything in the union is equal, pick the fastest method here
		else
		{
			$sin6_scope = $this.sin6_scope_struct.ToBytes()
		}

		[System.Runtime.InteropServices.Marshal]::Copy($Data16_1, 0, $Mem, $Data16_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data16_2, 0, $Mem.ToInt64() + 2, $Data16_2.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem.ToInt64() + 4, $Data32.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Addr, 0, $Mem.ToInt64() + 8, $Addr.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($sin6_scope, 0, $Mem.ToInt64() + 8 + $Addr.Length, $sin6_scope.Length)

		# Normalize with the internal variables
		$this.FromUnmanaged($Mem) | Out-Null

		return $Mem
	}

	[SOCKADDR_IN6] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[Int16[]] $Data16_1 = [Int16[]]::new(1)
		[UInt16[]] $Data16_2 = [UInt16[]]::new(1)
		[UInt32[]] $Data32_1 = [UInt32[]]::new(1)
		[UInt32[]] $Data32_2 = [UInt32[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data16_1, 0, $Data16_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 2, $Data16_2, 0, $Data16_2.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $Data32_1, 0, $Data32_1.Length)
		$this.sin6_addr = ([IN6_ADDR]::new()).FromUnmanaged($Unmanaged.ToInt64() + 8)

		$Mem = $Unmanaged.ToInt64() + 8 + $this.sin6_addr.Size()
		[System.Runtime.InteropServices.Marshal]::Copy($Mem, $Data32_2, 0, $Data32_2.Length)
		$this.sin6_scope_struct = ([SCOPE_ID]::new()).FromUnmanaged($Mem)
		$this.sin6_scope_id = $Data32_2[0]
		$this.sin6_scope_struct_internal = ([SCOPE_ID]::new()).FromUnmanaged($Mem)
		$this.sin6_scope_id_internal = $Data32_2[0]

		$this.sin6_family = $Data16_1[0]
		$this.sin6_port = $Data16_2[0]
		$this.sin6_flowcontrol = $Data32_1[0]

		return $this
	}
}
