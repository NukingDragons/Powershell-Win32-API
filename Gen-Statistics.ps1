function Calc-Statistic
{
	param(
		[Parameter(Position = 0, Mandatory = $True)][String] $Path,
		[Parameter(Position = 1, Mandatory = $True)][String] $ModuleName
	)

	function dumpbin
	{
		param(
			[Parameter(Position = 0, Mandatory = $True)][String] $File
		)

		# Adjust this as needed
		$output = & "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC\14.34.31933\bin\Hostx64\x86\dumpbin.exe" /exports $File

		$Res = @()

		$i = 0
		$output | foreach {
			$i += 1

			if ($_ -match "  Summary")
			{
				# I HAVE NO CLUE WHY THE RETURN HAS TO BE HERE AND NOT THE END OF THE FUNCTION FOLLOWING THE EXIT/BREAK/WHATEVER
				# I HATE POWERSHELLLLLLLL
				return $Res | Select-Object -SkipLast 1
				exit
			}

			if ($i -ge 20)
			{
				$parts = $_ -split "\s+", 5

				if ($parts[4] -match "forwarded to")
				{
					$parts[4] = $parts[3]
					$parts[3] = ""
				}

				$item = New-Object -Type PSObject -Property @{
					ordinal = $parts[1]
					hint = $parts[2]
					RVA = $parts[3]
					name = $parts[4]
				}

				$Res += $item
			}
		}
	}

	$Scripts = (Get-ChildItem -Recurse -Filter "*.ps1" $ModuleName).Name -replace ".ps1"

	$AllSymbols = (dumpbin ($Path + '\' + $ModuleName)).Name
	$ImplementedSymbols = $AllSymbols | Where-Object { $Scripts -contains $_ }

	$Percentage = ($ImplementedSymbols.Length / $AllSymbols.Length).ToString('P2')

	return "| " + $ModuleName + " | " + $Percentage + " |"
}

echo "| Module | Percentage Implemented |"
echo "| - | - |"
Calc-Statistic "C:\Windows\System32" "kernel32.dll"
Calc-Statistic "C:\Windows\System32" "ws2_32.dll"
