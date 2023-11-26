# Depends on LoadFunction.ps1
# Depends on structures/SOCKADDR_IN.ps1
# Depends on structures/SOCKADDR_IN6.ps1
# Depends on structures/QOS.ps1
# Depends on structures/WSABUF.ps1
function WSAConnect
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][IntPtr] $s,
		[Parameter(Position = 1, Mandatory = $True)]
		[ValidateScript({
			if($_.GetType().Name -eq "SOCKADDR_IN" -or $_.GetType().Name -eq "SOCKADDR_IN6")
			{
				return $true
			}
			else
			{
				throw "Expected a SOCKADDR_IN object or a SOCKADDR_IN6 object"
			}
			})]
		[System.Object] $name,
		[Parameter(Position = 2, Mandatory = $True)][Int32] $namelen,
		[Parameter(Position = 3                   )][WSABUF] $lpCallerData = $null,
		[Parameter(Position = 4                   )][WSABUF] $lpCalleeData = $null,
		[Parameter(Position = 5                   )][QOS] $lpSQOS = $null,
		[Parameter(Position = 6                   )][QOS] $lpGQOS = $null
	)

	if ($global:WSAConnect -eq $null)
	{
		$global:WSAConnect = LoadFunction ws2_32.dll WSAConnect @([IntPtr], [IntPtr], [Int32], [IntPtr], [IntPtr], [IntPtr], [IntPtr]) ([UInt64])
	}

	$nameMem = $name.ToUnmanaged()
	$lpCallerDataMem = [IntPtr]::Zero
	$lpCalleeDataMem = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(([WSABUF]::new()).Size())
	$lpSQOSMem = [IntPtr]::Zero
	$lpGQOSMem = [IntPtr]::Zero

	if ($lpCallerData) { $lpCallerDataMem = $lpCallerData.ToUnmanaged() }
	if ($lpSQOS) { $lpSQOS.ToUnmanaged() }
	if ($lpGQOS) { $lpGQOSMem = $lpGQOS.ToUnmanaged() }

	$ret = $global:WSAConnect.Invoke($s, $nameMem, $namelen, $lpCallerDataMem, $lpCalleeDataMem, $lpSQOSMem, $lpGQOSMem)

	if ($lpCalleeData) { $lpCalleeData.FromUnmanaged($lpCalleeDataMem) | Out-Null }

	$name.FreeUnmanaged($nameMem)
	if ($lpCallerData) { $lpCallerData.FreeUnmanaged($lpCallerDataMem) }
	([WSABUF]::new()).FreeUnmanaged($lpCalleeDataMem)
	if ($lpSQOS) { $lpSQOS.FreeUnmanaged($lpSQOSMem) }
	if ($lpGQOS) { $lpGQOS.FreeUnmanaged($lpGQOSMem) }

	return $ret
}
