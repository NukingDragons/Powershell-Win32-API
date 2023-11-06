class PROCESS_INFORMATION
{
	[IntPtr] $hProcess
	[IntPtr] $hThread
	[UInt32] $dwProcessId
	[UInt32] $dwThreadId

    [IntPtr] ToUnmanaged()
    {
        $Mem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(16)
        [Byte[]] $Raw = [Byte[]]::new(16)
        [System.Runtime.InteropServices.Marshal]::Copy($Raw, 0, $Mem, 6)

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

	[Void] FreeUnmanaged([IntPtr] $Unmanaged)
	{
		[System.Runtime.InteropServices.Marshal]::FreeHGlobal($Unmanaged)
	}
}
