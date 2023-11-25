# Depends on BaseWin32Class.ps1
class BaseWin32Union : BaseWin32Class
{
	[Void] Update()
	{
		[IntPtr] $Raw = $this.ToUnmanaged()
		$this.FromUnmanaged($Raw) | Out-Null
		$this.FreeUnmanaged($Raw)
	}
}
