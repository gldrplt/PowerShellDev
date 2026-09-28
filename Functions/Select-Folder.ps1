function Select-Folder {    # Select Folder with Windows Explorer
    param(
        [string]$Title = "Select Folder",
        [string]$InitialDirectory
    )

    $app = New-Object -ComObject Shell.Application

    $folder = $app.BrowseForFolder(
        0,
        $Title,
        0,
        $InitialDirectory
    )

    if ($folder) {
        $folder.Self.Path
    }
}

