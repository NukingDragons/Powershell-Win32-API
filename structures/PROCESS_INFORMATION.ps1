# Depends on BaseWin32Class.ps1
class PROCESS_INFORMATION : BaseWin32Class
{
	[IntPtr] $hProcess
	[IntPtr] $hThread
	[UInt32] $dwProcessId
	[UInt32] $dwThreadId

	[UInt64] Size()
	{
		return ([System.IntPtr]::Size * 2) + 8
	}

    [IntPtr] ToUnmanaged()
    {
		$Size = $this.Size()
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($Size)
        [Byte[]] $Raw = [Byte[]]::new($Size)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, $Size)

		[IntPtr[]] $Pointers = @($this.hProcess, $this.hThread)
		[UInt32[]] $Data32 = @($this.dwProcessId, $this.dwThreadId)
        [System.Runtime.InteropServices.Marshal]::Copy($Pointers, 0, $Mem, $Pointers.Length)
        [System.Runtime.InteropServices.Marshal]::Copy($Data32, 0, $Mem.ToInt64() + ($Pointers.Length * [System.IntPtr]::Size), $Data32.Length)

        return $Mem
    }

	[PROCESS_INFORMATION] FromUnmanaged([IntPtr] $Unmanaged)
	{
		[IntPtr[]] $Pointers = [IntPtr[]]::new(2)
		[UInt32[]] $Data32 = [UInt32[]]::new(2)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged, $Pointers, 0, $Pointers.Length)
		[System.Runtime.InteropServices.Marshal]::Copy($Unmanaged.ToInt64() + ($Pointers.Length * [System.IntPtr]::Size), $Data32, 0, $Data32.Length)

		$this.hProcess = $Pointers[0]
		$this.hThread = $Pointers[1]
		$this.dwProcessId = $Data32[0]
		$this.dwThreadId = $Data32[1]

        return $this
	}
}
