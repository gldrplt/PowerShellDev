# Remove files older than <num> days from -Folder
# -Filter determines file types to remove
# Use redirection 6> <filename> to capture the output of this function to a log file

<#
.SYNOPSIS
Remove files from $Folder based on age and/or file type.

.DESCRIPTION
Options:
    -Folder  : Path to folder containing files to remove
    -Days    : Remove files older than this number of days (default 30)
    -Filter  : File type filter (default *.*)
	-LogFile : Log file to write to (default .\default.log)
    -Test    : Test mode, do not delete files

Alias: rof

.NOTES

Author: Paul McDonald
Version: 1.0.0

.EXAMPLE
PS> Remove-OldFiles -Folder "C:\Batch\Backup-Z370-Logs" -Filter "*.log" -Days 30 -Test

#>
function Remove-OldFiles {	# Remove files based on age/type
	[CmdletBinding()]
    param(
        [string]$Folder,
        [int]$Days = 30,
		[string]$Filter = "*.*",
        [string]$LogFile = ".\default.log",
		[switch]$Test        
    )

# Check Folder exists
	if (-not (Test-Path $Folder -PathType Container)) {
		Add-Content -Path $LogFile -Value "Folder does not exist: $Folder"
		return
	}

    $timestamp = Get-Date -Format "ddd MM/dd/yyyy HH:mm:sstt"

# Get files that match criteria
# Force $files to be an array using @(...)
	if ($PSBoundParameters.ContainsKey('Days')) {
		$files = @(
			Get-ChildItem -Path $Folder -File -Filter $Filter |
				Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Days) } |
				Sort-Object LastWriteTime
		)
	}
	else {
		$files = @(
			Get-ChildItem -Path $Folder -File -Filter $Filter |
				Sort-Object LastWriteTime
		)
	}

    if ($files) {
        $logcnt = $files.Count
    }
    else {
        $logcnt = 0
	}

# Clear log
# Force UTF-8 encoding instead of UTF-16
#"" | Set-Content -Path $LogFile -Encoding utf8

	
# create message for log file
	$msg = @"
Folder : $Folder 
Filter : $Filter
"@
	
	if ($PSBoundParameters.ContainsKey('Days')) {
		$msg = $msg + "`nRemove files older than $Days Days"
	}
	if ($logcnt -eq 0){	# if no files found
		if ($PSBoundParameters.ContainsKey('Days')) {
			$msg = $msg + "`n`nNo files of type $Filter older than $Days days found in $Folder`n"
		}
		else {
			$msg = $msg + "`n`nNo files of type $Filter found in $Folder`n"
		}
	}
	
    if ($Test) {
        $msg2 = "`n$timestamp Remove-OldFiles running in Test Mode...`n"
		$msg2 = (Color-Text "$msg2" "Yellow")
    }
    else {
        $msg2 = "`n$timestamp Removing the following files`n"
		$msg2 = (Color-Text "$msg2" "Green")
    }
	Add-Content -Path $LogFile -Value $msg2
	Add-Content -Path $LogFile -Value $msg

# show files
	if ($files){
		$msg3 =
			$files |
			Sort-Object @{ Expression = { $_.LastWriteTime.Date } }, Name |
			Select-Object Name, LastWriteTime |
			Format-Table -AutoSize |
			Out-String
		Add-Content -Path $LogFile -Value $msg3
	}

# Remove files
	if ($files -and -not $Test) {
        $files | Remove-Item -Force
	}
	
# Return $logcnt	
    return $logcnt
}

