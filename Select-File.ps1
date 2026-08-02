function Select-File { # Select File with Windows Exporer
#
# examples:
# $file = Select-File -Filter "PDF Files (*.pdf)|*.pdf"
# $file = Select-File -InitialDirectory "E:\Picture Library"
# $files = Select-File -Filter "JPEG Files (*.jpg)|*.jpg" -MultiSelect

    param(
        [string]$InitialDirectory = (Get-Location).Path,
        [string]$Filter = "All Files (*.*)|*.*",
        [string]$Title = "Select File",
        [switch]$MultiSelect
    )

    Add-Type -AssemblyName System.Windows.Forms

    $dialog = [System.Windows.Forms.OpenFileDialog]::new()
    $dialog.Title = $Title
    $dialog.InitialDirectory = $InitialDirectory
    $dialog.Filter = $Filter
    $dialog.Multiselect = $MultiSelect.IsPresent


    if ($dialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # $dialog.FileName
        $file = $dialog.FileNames
		return Get-Item -LiteralPath $dialog.FileNames
        #return ,$file	# always return an array
    }
}

