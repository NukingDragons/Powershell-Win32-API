function Merger()
{
    [CmdletBinding(DefaultParameterSetName="FunctionsMerger")]
	param(
		[Parameter(Position = 0, Mandatory = $True, ParameterSetName = "FunctionsMerger")]
		[String[]] $FunctionsArray,

		[Parameter(Position = 0, Mandatory = $True, ParameterSetName = "FileMerger")]
		[String] $InputFile
	)

	function FetchFiles()
	{
		param(
			[Parameter(Position = 0, Mandatory = $True)][String[]] $FileArray
		)

		foreach ($File in $FileArray)
		{
			$Depends = @(((Get-Content $File | Select-String "# Depends on ") -replace "# Depends on " -replace "LoadFunction.ps1") | Where-Object { $_ -ne "" })
			if ($Depends.Length -gt 0)
			{
				echo $Depends
				FetchFiles $Depends
			}
		}
	}

	[System.Collections.ArrayList] $FetchedFiles = @("LoadFunction.ps1")

	if ($InputFile)
	{
		$FetchedFiles += FetchFiles @($InputFile) | Sort-Object | Get-Unique
	}

	if ($FunctionsArray)
	{
		[System.Collections.ArrayList] $Files = @()

		foreach ($Function in $FunctionsArray)
		{
			$File = $Function + ".ps1"
			$FoundFile = Get-ChildItem -Recurse -Filter $File

			if ($FoundFile)
			{
				[String] $FullPath = $FoundFile.Directory
				$FullPath += "\"
				$FullPath += $FoundFile.Name
				$Files.Add($FullPath) | Out-Null
			}
			else
			{
				throw 'Function "' + $Function + '" not found'
			}
		}

		$FetchedFiles += FetchFiles $Files | Sort-Object | Get-Unique

		foreach ($File in $Files)
		{
			$FetchedFiles.Add($File) | Out-Null
		}
	}

	foreach ($File in $FetchedFiles)
	{
		Get-Content $File
	}

	if ($InputFile)
	{
		Get-Content $InputFile
	}
}
