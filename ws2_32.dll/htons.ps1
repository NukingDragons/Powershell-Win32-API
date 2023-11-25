# Depends on LoadFunction.ps1
function htons
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][UInt16] $hostshort
	)

	if ($global:htons -eq $null)
	{
		$global:htons = LoadFunction ws2_32.dll htons @([UInt16]) ([UInt16])
	}

	$ret = $global:htons.Invoke($hostshort)

	return $ret
}
