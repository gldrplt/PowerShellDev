#	Show-Colors.ps1
function Show-Colors {	# Show Color Swatches
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "System.Drawing Colors"
$form.Size = New-Object System.Drawing.Size(1600,1200)
$form.StartPosition = "CenterScreen"
$form.AutoScroll = $true

$flow = New-Object System.Windows.Forms.FlowLayoutPanel
$flow.Dock = "Fill"
$flow.WrapContents = $true
$flow.AutoScroll = $true
$flow.Padding = New-Object System.Windows.Forms.Padding(10)
$flow.FlowDirection = "LeftToRight"

$form.Controls.Add($flow)

# Get all named colors
$colors = [System.Drawing.KnownColor].GetEnumNames() |
          Sort-Object

foreach ($name in $colors) {

    $color = [System.Drawing.Color]::FromName($name)

    # Container panel for each color
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Width = 120
    $panel.Height = 120
    $panel.Margin = New-Object System.Windows.Forms.Padding(5)

    # Color swatch
    $swatch = New-Object System.Windows.Forms.PictureBox
    $swatch.Width = 100
    $swatch.Height = 60
    $swatch.BackColor = $color
    $swatch.BorderStyle = 'FixedSingle'
    $swatch.Location = New-Object System.Drawing.Point(10,5)

    # Color name
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $name
    $label.AutoSize = $false
    $label.Width = 100
    $label.Height = 20
    $label.Location = New-Object System.Drawing.Point(10,70)
    $label.TextAlign = 'MiddleCenter'

    $panel.Controls.Add($swatch)
    $panel.Controls.Add($label)
    $flow.Controls.Add($panel)
}

[void]$form.ShowDialog()

}