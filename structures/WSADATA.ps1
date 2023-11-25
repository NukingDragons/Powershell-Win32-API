# Depends on BaseWin32Class.ps1
class WSADATA : BaseWin32Class
{
	[UInt16] $wVersion
	[UInt16] $wHighVersion
	[String] $szDescription
	[String] $szSystemStatus
	[UInt16] $iMaxSockets
	[UInt16] $iMaxUdpDg
	[String] $lpVendorInfo

	[UInt64] Size()
	{
		return [System.IntPtr]::Size + 255 + 127 + 10
	}

    [IntPtr] ToUnmanaged()
    {
		[Byte[]] $szAnsis = [Byte[]]::new(255 + 127 + 2)

		if ($this.szDescription)
		{
			$szDescriptionStr = $this.szDescription.substring(0, [System.Math]::Min(255, $this.szDescription.Length))
			$szDescriptionAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($szDescriptionStr)
			[System.Runtime.InteropServices.Marshal]::Copy($szDescriptionAnsi, $szAnsis, 0, $szDescriptionStr.Length)
			[System.Runtime.InteropServices.Marshal]::FreeHGlobal($szDescriptionAnsi)
		}

		if ($this.szSystemStatus)
		{
			$szSystemStatusStr = $this.szSystemStatus.substring(0, [System.Math]::Min(127, $this.szSystemStatus.Length))
			$szSystemStatusAnsi = [System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($szSystemStatusStr)
			[System.Runtime.InteropServices.Marshal]::Copy($szSystemStatusAnsi, $szAnsis, 256, $szSystemStatusStr.Length)
			[System.Runtime.InteropServices.Marshal]::FreeHGlobal($szSystemStatusAnsi)
		}

		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[UInt16[]] $Data16_1 = @($this.wVersion, $this.wHighVersion)
		[UInt16[]] $Data16_2 = @($this.iMaxSockets, $this.iMaxUdpDg)

		[IntPtr[]] $lpVendorInfoAnsi = [IntPtr]::Zero

		if ($this.lpVendorInfo)
		{
			$lpVendorInfoAnsi = @([System.Runtime.InteropServices.Marshal]::StringToHGlobalAnsi($this.lpVendorInfo))
		}

		[System.Runtime.InteropServices.Marshal]::Copy($Data16_1, 0, $Mem, $Data16_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($szAnsis, 0, $Mem.ToInt64() + 4, $szAnsis.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Data16_2, 0, $Mem.ToInt64() + 4 + $szAnsis.Length, $Data16_2.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($lpVendorInfoAnsi, 0, $Mem.ToInt64() + 8 + $szAnsis.Length, $lpVendorInfoAnsi.Length)

        return $Mem
    }

	[WSADATA] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt16[]] $Data16_1 = [UInt16[]]::new(2)
		[Byte[]] $szAnsis = [Byte[]]::new(255 + 127 + 2)
		[UInt16[]] $Data16_2 = [UInt16[]]::new(2)
		[IntPtr[]] $lpVendorInfoAnsi = [IntPtr[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data16_1, 0, $Data16_1.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4, $szAnsis, 0, $szAnsis.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 4 + $szAnsis.Length, $Data16_2, 0, $Data16_2.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 8 + $szAnsis.Length, $lpVendorInfoAnsi, 0, $lpVendorInfoAnsi.Length)

		$this.wVersion = $Data16_1[0]
		$this.wHighVersion = $Data16_1[1]

		$szDescriptionAnsi = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(256)
		[System.Runtime.InteropServices.Marshal]::Copy($szAnsis, 0, $szDescriptionAnsi, 255)
		$this.szDescription = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($szDescriptionAnsi)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($szDescriptionAnsi)

		$szSystemStatusAnsi = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(128)
		[System.Runtime.InteropServices.Marshal]::Copy($szAnsis, 256, $szSystemStatusAnsi, 127)
		$this.szSystemStatus = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($szSystemStatusAnsi)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($szSystemStatusAnsi)

		$this.iMaxSockets = $Data16_2[0]
		$this.iMaxUdpDg = $Data16_2[1]

		$this.lpVendorInfo = [System.Runtime.InteropServices.Marshal]::PtrToStringAnsi($lpVendorInfoAnsi[0])

		return $this
	}

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[IntPtr[]] $lpVendorInfoAnsi = [IntPtr[]]::new(1)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + 8 + 255 + 127 + 2, $lpVendorInfoAnsi, 0, $lpVendorInfoAnsi.Length)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($lpVendorInfoAnsi[0])
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
