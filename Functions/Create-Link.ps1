# Create-Link.ps1
#   Create symbolic Link

function Create-Link {
	param(
		[switch]$Test
	)
	
    # Check for Administrator privileges
	if (-not $Test){
		$isAdmin = (
			[Security.Principal.WindowsPrincipal] `
				[Security.Principal.WindowsIdentity]::GetCurrent()
		).IsInRole(
			[Security.Principal.WindowsBuiltInRole]::Administrator
		)

		if (-not $isAdmin) {
			Write-Host "Create-Link function needs elevated privileges ..." -ForegroundColor Red
			Write-Host "Launch Powershell as administrator ...`n" -ForegroundColor Red
			return
		}
	}
    Write-Host "`nCreate symbolic link`n" -ForegroundColor Cyan
    Write-Host "Running as Administrator`n" -ForegroundColor Cyan

    # Select target file
	Write-Host "Select Target File" - ForegroundColor Cyan
    $source = Select-File -Title "Select Symbolic Link Target File"
	Write-Host "`nSelected Target File: $($source.FullName)`n" -ForegroundColor Cyan

    if (-not $source) {
        Write-Host "No file selected." -ForegroundColor Red
        return
    }

    $linkname = Read-Host "Enter symbolic link name"

	# Validate folder location
	$folder = Get-Location
	$ValidAnswer = $false
	do {
		do {
			$Answer = Read-Host "Create link in folder $folder (Y/N) "

			if ([string]::IsNullOrWhiteSpace($Answer)) {
				$Answer = "N"
			}

			if ($Answer -in 'y','Y'){
				break
			} elseif ($Answer -in 'n','N'){
				$folder = (Select-Folder -Title "Select folder for Symbolic Link" ).FullName
			} else {
				Write-Host "Enter Y or N." -ForegroundColor Yellow
				$ValidAnswer = $false
			}

		} until ($ValidAnswer)

		break	

	} until ($folder)

	# Create Symbolic Link
	Set-Location $folder
	if (-not $Test){
    New-Item -ItemType SymbolicLink `
        -Path $linkname `
        -Target $source.FullName
	}
	Write-Host "`nSymbolic Link $linkname `nCreated in $folder`n" -ForegroundColor Cyan
}