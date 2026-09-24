<#
.SYNOPSIS
Lists all user-defined functions.

.DESCRIPTION
Searches the Batch and Dev folders for PowerShell scripts and
displays each function with its description and source file.

ALIAS: listf

.NOTES

Author: Paul McDonald
Version: 1.0.0

This command only recognizes functions declared with the
standard syntax:

    "function Name {"

Comments following the function declaration are used as the
brief description displayed by List-Functions.

.EXAMPLE
PS> List-Functions

Displays all functions in the default folders.

#>
function List-Functions {	# List user defined functions

	
	[CmdletBinding()]
	
    $Tgt = "C:\Batch\myfunctions.ps1"
	Write-Host "`nFunctions from $Tgt" -ForegroundColor yellow
	Get-Content $Tgt |
		ForEach-Object {
			if ($_ -cmatch '^\s*function\s+(?<Function>[^\s({]+)\s*\{?\s*(?<Comment>#.*)?$') {
				[PSCustomObject]@{
					Function = $Matches.Function
					Comment  = ($Matches.Comment -replace '^\s*#\s*','')
				}
			}
		} |
		Sort-Object Function |
		Format-Table Function, Comment -AutoSize    

#	functions from c:\projects\dev	
	$Tgt = "C:\Projects\Dev"
	Write-Host "`Functions from $Tgt\*.ps1" -ForegroundColor yellow

	Get-ChildItem $Tgt\*.ps1 |
    ForEach-Object {
        $file = $_.Name

        Get-Content $_ |
            Where-Object { $_ -match '^\s*function\s+.*\{' } |
            ForEach-Object {
                if ($_ -match '^\s*function\s+([^( {]+).*?(#.*)?$') {
                    [PSCustomObject]@{
                        Function = $matches[1]
                        Comment  = if ($matches[2]) {
                                       $matches[2] -replace '^\s*#\s*',''
                                   }
                                   else {
                                       ''
                                   }
                        File      = $file
                    }
                }
            }
    } |
    Sort-Object Function |
    Format-Table Function, Comment, File -AutoSize

#	functions from $PROFILE
	$Tgt = $PROFILE
	Write-Host "`Functions from $Tgt" -ForegroundColor yellow
	Get-Content $Tgt |
		ForEach-Object {
			if ($_ -cmatch '^\s*function\s+(?<Function>[^\s({]+)\s*\{?\s*(?<Comment>#.*)?$') {
				[PSCustomObject]@{
					Function = $Matches.Function
					Comment  = ($Matches.Comment -replace '^\s*#\s*','')
				}
			}
		} |
		Format-Table Function, Comment -AutoSize

	Write-Host
}
