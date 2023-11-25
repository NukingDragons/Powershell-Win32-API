# Depends on BaseWin32Class.ps1
# Depends on structures/IN6_ADDR_U.ps1
class IN6_ADDR : BaseWin32Class
{
	[IN6_ADDR_U] $u = [IN6_ADDR_U]::new()

	[UInt64] Size()
	{
		return $this.u.Size()
	}

    [IntPtr] ToUnmanaged()
    {
		return $this.u.ToUnmanaged()
    }

	[IN_ADDR] FromUnmanaged([IntPtr] $Unmanaged)
	{
		$this.u = ([IN6_ADDR_U]::new()).FromUnamanged($Unmanaged)

		return $this
	}

	[IN6_ADDR] FromBytes([Byte[]] $Bytes)
	{
		$this.u = $this.u.FromBytes($Bytes)

		return $this
	}
}
