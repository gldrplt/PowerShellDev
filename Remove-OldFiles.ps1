# Remove files older than <num> days from -Folder
# -Filter determines file types to remove
# Use redirection 6> <filename> to capture the output of this function to a log file

<#
.SYNOPSIS
Remove files from $Folder based on age and/or file type.

.DESCRIPTION
Options:
    -Folder : Path to folder containing files to remove
    -Days   : Remove files older than this number of days (default 30)
    -Filter : File type filter (default *.*)
    -Test   : Test mode, do not delete files

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
        [switch]$Test        
    )

# Check Folder exists
	if (-not (Test-Path $Folder -PathType Container)) {
		Write-Information "Folder does not exist: $Folder"
		return
	}

    $timestamp = Get-Date -Format "ddd MM/dd/yyyy HH:mm:sstt"

# Get files that match criteria    	
	if ($PSBoundParameters.ContainsKey('Days')) {
		$files = Get-ChildItem -Path $Folder -File -Filter $Filter |
			Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$Days) } |
			Sort-Object LastWriteTime
	}
	else {
		$files = Get-ChildItem -Path $Folder -File -Filter $Filter |
			Sort-Object LastWriteTime
	}

    if ($files) {
        $logcnt = $files.Count
    }
    else {
        $logcnt = 0
	}
	
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
			$msg = $msg + "`nNo files of type $Filter older than $Days days found in $Folder`n"
		}
		else {
			$msg = $msg + "`nNo files of type $Filter found in $Folder`n"
		}
	}
	
    if ($Test) {
        Write-Information "`n$timestamp Remove-OldFiles running in Test Mode...`n"
		Write-Information "$msg"
    }
    else {
        Write-Information "`n$timestamp Removing the following files`n"
		Write-Information "$msg"
    }

# show files
	if ($files){
		$files |
		Sort-Object @{ Expression = { $_.LastWriteTime.Date } }, Name |
		Select-Object Name, LastWriteTime |
		Format-Table -AutoSize |
		Out-String |
		Write-Information
	}

# Remove files
	if ($files -and -not $Test) {
        $files | Remove-Item -Force
	}
	
# Return $logcnt	
    return $logcnt
}
