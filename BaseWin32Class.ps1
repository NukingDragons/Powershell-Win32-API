class BaseWin32Class
{
	[Bool] Equals($rhs_class)
	{
		[Byte[]] $lhs = $this.ToBytes()
		[Byte[]] $rhs = $rhs_class.ToBytes()

		$Res = $True

		if ($lhs.Length -ne $rhs.Length)
		{
			$Res = $False
		}
		else
		{
			for ($i = 0; $i -le $lhs.Length; $i += 1)
			{
				if ($lhs[$i] -ne $rhs[$i])
				{
					$Res = $False
					break
				}
			}
		}

		return $Res
	}

	[Byte[]] ToBytes()
	{
		[IntPtr] $Unmanaged = $this.ToUnmanaged()

		[UInt64] $Size = $this.Size()
		[Byte[]] $Res = [Byte[]]::new($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Res, 0, $Size)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)

		return $Res
	}

	[System.Object] FromBytes([Byte[]] $Bytes)
	{
		$Size = $this.Size()
		[Byte[]] $Raw = [Byte[]]::new($Size)
		$Unmanaged = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
		[System.Runtime.InteropServices.Marshal]::Copy($Raw, $Unmanaged, 0, $Raw.Length)

        $Length = $Bytes.Length
        if ($Length -gt $Size) { $Length = $Size }

		[System.Runtime.InteropServices.Marshal]::Copy($Bytes, $Unmanaged, 0, $Length)

		$this.FromUnmanaged($Unmanaged) | Out-Null
		$this.FreeUnmanaged($Unmanaged)

		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}

	[Void] Update()
	{
		# Do nothing, this is a union only thing
		# This function is only provided so that non-union classes won't crash if this method is used
	}
}
