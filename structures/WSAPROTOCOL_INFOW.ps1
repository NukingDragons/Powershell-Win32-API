# Depends on BaseWin32Class.ps1
# Depends on structures/GUID.ps1
# Depends on structures/WSAPROTOCOLCHAIN.ps1
class WSAPROTOCOL_INFOW : BaseWin32Class
{
	[UInt32] $dwServiceFlags1
	[UInt32] $dwServiceFlags2
	[UInt32] $dwServiceFlags3
	[UInt32] $dwServiceFlags4
	[UInt32] $dwProviderFlags
	[GUID] $ProviderId = [GUID]::new()
	[UInt32] $dwCatalogEntryId
	[WSAPROTOCOLCHAIN] $ProtocolChain = [WSAPROTOCOLCHAIN]::new()
	[Int32] $iVersion
	[Int32] $iAddressFamily
	[Int32] $iMaxSockAddr
	[Int32] $iMinSockAddr
	[Int32] $iSocketType
	[Int32] $iProtocol
	[Int32] $iProtocolMaxOffset
	[Int32] $iNetworkByteOrder
	[Int32] $iSecurityScheme
	[UInt32] $dwMessageSize
	[UInt32] $dwProviderReserved
	[String] $szProtocol

	[UInt64] Size()
	{
		return $this.ProviderID.Size() + $this.ProtocolChain.Size() + (256 * 2) + 68
	}

    [IntPtr] ToUnmanaged()
    {
		[Byte[]] $szUnis = [Byte[]]::new(255 + 1)

		if ($this.szProtocol)
		{
			$szProtocolStr = $this.szProtocol.substring(0, [System.Math]::Min(255, $this.szProtocol.Length))
			$szProtocolUni = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($szProtocolStr)
			[System.Runtime.InteropServices.Marshal]::Copy($szProtocolUni, $szUnis, 0, $szProtocolStr.Length)
			[System.Runtime.InteropServices.Marshal]::FreeHGlobal($szProtocolUni)
		}

		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[UInt32[]] $Data32_1 = @($this.dwServiceFlags1, $this.dwServiceFlags2, $this.dwServiceFlags3, $this.dwServiceFlags4, $this.dwProviderFlags)
		[Byte[]] $ProviderIdBytes = $this.ProviderId.ToBytes()
		[UInt32[]] $Data32_2 = @($this.dwCatalogEntryId)
		[Byte[]] $ProtocolChainBytes = $this.ProtocolChain.ToBytes()
		[Int32[]] $Data32_3 = @($this.iVersion, $this.iAddressFamily, $this.iMaxSockAddr, $this.iMinSockAddr, $this.iSocketType, $this.iProtocol, $this.iProtocolmaxOffset, $this.iNetworkByteOrder, $this.iSecurityScheme)
		[UInt32[]] $Data32_4 = @($this.dwMessageSize, $this.dwProviderReserved)

		[System.Runtime.InteropServices.Marshal]::Copy($Data32_1, 0, $Mem, $Data32_1.Length)
		$Offset = $Data32_1.Length * 4
		[System.Runtime.InteropServices.Marshal]::Copy($ProviderIdBytes, 0, $Mem.ToInt64() + $Offset, $ProviderIdBytes.Length)
		$Offset += $ProviderIdBytes.Length
		[System.Runtime.InteropServices.Marshal]::Copy($Data32_2, 0, $Mem.ToInt64() + $Offset, $Data32_2.Length)
		$Offset += $Data32_2.Length * 4
		[System.Runtime.InteropServices.Marshal]::Copy($ProtocolChainBytes, 0, $Mem.ToInt64() + $Offset, $ProtocolChainBytes.Length)
		$Offset += $ProtocolChainBytes.Length
		[System.Runtime.InteropServices.Marshal]::Copy($Data32_3, 0, $Mem.ToInt64() + $Offset, $Data32_3.Length)
		$Offset += $Data32_3.Length * 4
		[System.Runtime.InteropServices.Marshal]::Copy($Data32_4, 0, $Mem.ToInt64() + $Offset, $Data32_4.Length)
		$Offset += $Data32_4.Length * 4
		[System.Runtime.InteropServices.Marshal]::Copy($szUnis, 0, $Mem.ToInt64() + $Offset, $szUnis.Length)

        return $Mem
    }

	[WSAPROTOCOL_INFOW] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[UInt32[]] $Data32_1 = [UInt32[]]::new(5)
		[UInt32[]] $Data32_2 = [UInt32[]]::new(1)
		[Int32[]] $Data32_3 = [Int32[]]::new(9)
		[UInt32[]] $Data32_4 = [UInt32[]]::new(2)
		[Byte[]] $szUnis = [Byte[]]::new((255 + 1) * 2)

		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Data32_1, 0, $Data32_1.Length)
		$Offset = $Data32_1.Length * 4
		$this.ProviderId = ([GUID]::new()).FromUnmanaged($Unmanaged.ToInt64() + $Offset)
		$Offset += $this.ProviderId.Size()
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data32_2, 0, $Data32_2.Length)
		$Offset += $Data32_2.Length * 4
		$this.ProtocolChain = ([WSAPROTOCOLCHAIN]::new()).FromUnmanaged($Unmanaged.ToInt64() + $Offset)
		$Offset += $this.ProtocolChain.Size()
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data32_3, 0, $Data32_3.Length)
		$Offset += $Data32_3.Length * 4
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $Data32_4, 0, $Data32_4.Length)
		$Offset += $Data32_4.Length * 4
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + $Offset, $szUnis, 0, $szUnis.Length)

		$this.dwServiceFlags1 = $Data32_1[0]
		$this.dwServiceFlags2 = $Data32_1[1]
		$this.dwServiceFlags3 = $Data32_1[2]
		$this.dwServiceFlags4 = $Data32_1[3]
		$this.dwProviderFlags = $Data32_1[4]
		$this.dwCatalogEntryId = $Data32_2[0]
		$this.iVersion = $Data32_3[0]
		$this.iAddressFamily = $Data32_3[1]
		$this.iMaxSockAddr = $Data32_3[2]
		$this.iMinSockAddr = $Data32_3[3]
		$this.iSocketType = $Data32_3[4]
		$this.iProtocol = $Data32_3[5]
		$this.iProtocolMaxOffset = $Data32_3[6]
		$this.iNetworkByteOrder = $Data32_3[7]
		$this.iSecurityScheme = $Data32_3[8]
		$this.dwMessageSize = $Data32_4[0]
		$this.dwProviderReserved = $Data32_4[1]

		$szProtocolUni = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(256 * 2)
		[System.Runtime.InteropServices.Marshal]::Copy($szUnis, 0, $szProtocolUni, 255 * 2)
		$this.szProtocol = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($szProtocolUni)
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($szProtocolUni)

		return $this
	}
}
