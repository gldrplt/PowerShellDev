# Toggle-NewViewer.ps1
# This script toggles the visibility of a new viewer window in a PowerShell environment.

function Toggle-NewViewer {
    param(
        [switch]$Show
    )
    if ($Show) {
        # Code to show the new viewer window
        Write-Host "`nNewViewer background set to: $env:NewViewerBG`n"
        return
    }

    $background = "white"
    if ($env:NewViewerBG -eq "white") {
        $background = "black"
    }
    elseif ($env:NewViewerBG -eq "black") {
        $background = "white"
    }

    # Set the environment variable to the new background color
    $env:NewViewerBG = $background
    # Make persistent
    [Environment]::SetEnvironmentVariable("NewViewerBG", $background, "User")
    # Output the new background color to the console
    Write-Host "`nNewViewer background is now set to: $background`n"

}