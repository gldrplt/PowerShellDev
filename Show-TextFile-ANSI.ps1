#	Show-TextFile function
#param(
#    [string]$ShowFile
#)

function Show-TextFile-ANSI {	# Show text file in scrollable window

param(
    #[string]$ShowFile = "$PWD\stdout.txt"
    [string]$ShowFile
)

if (-not $ShowFile) {
    $ShowFile = Join-Path (Get-Location).Path 'stdout.txt'
}

# debug 
#Write-Host "Location = $((Get-Location).Path)"

    Add-Type -AssemblyName PresentationFramework

    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Backup Z370 Script"
        Width="900"
        Height="700"
        WindowStartupLocation="CenterScreen"
        FontSize="16"
        Background="Black">
    
    <Grid Margin="10">
    <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
    </Grid.RowDefinitions>

    <TextBlock Name="txtTitle"
            Grid.Row="0"
            FontSize="14"
            FontWeight="Bold"
            Foreground="White"
            TextWrapping="Wrap"
            Margin="0,0,0,10"/>

    <ListBox Name="listBox"
            Grid.Row="1"
            FontFamily="Consolas"
            FontSize="16"
            Foreground="White"
            Background="Black"
            Margin="0,0,0,10"
            ScrollViewer.HorizontalScrollBarVisibility="Auto"
            ScrollViewer.VerticalScrollBarVisibility="Auto"/>

    <Button Name="btnClose"
            Grid.Row="2"
            Content="Close"
            Width="80"
            HorizontalAlignment="Right"
            IsDefault="True"/>
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)

    # Set window title to show the file being displayed
    # $Window.Title = "Showing: $ShowFile"
    $txtTitle = $window.FindName("txtTitle")
    $listBox  = $window.FindName("listBox")
    $btnClose = $window.FindName("btnClose")

	# temp
	#Write-Host "ShowFile = [$ShowFile]"
	#Write-Host "args     = [$($args -join ', ')]"

    #$Path = (Resolve-Path $ShowFile).Path

    # Resolve path
    # if ([System.IO.Path]::IsPathRooted($ShowFile)) {
        # $Path = $ShowFile
    # }
    # else {
        # $Path = Join-Path $PWD $ShowFile
    # }

	if (-not [System.IO.Path]::IsPathFullyQualified($ShowFile)) {
		$ShowFile = Join-Path (Get-Location).Path $ShowFile
	}
	
	$Path = (Resolve-Path $ShowFile).Path	
	# temp
	# Write-Host "PWD      = [$PWD]"
	# Write-Host "ShowFile = [$ShowFile]"
	# Write-Host "Path     = [$Path]"


    # ANSI SGR color support
    function Add-AnsiLine {
        param([string]$Line)

        $textBlock = New-Object System.Windows.Controls.TextBlock
        $textBlock.FontFamily = New-Object System.Windows.Media.FontFamily("Consolas")
        $textBlock.FontSize = 16
        $textBlock.Foreground = [System.Windows.Media.Brushes]::White
        $textBlock.Background = [System.Windows.Media.Brushes]::Black

        $ansiPattern = "`e\[[0-9;]*m"
        $parts = [regex]::Split($Line, $ansiPattern)
        $matches = [regex]::Matches($Line, $ansiPattern)

        $foreground = [System.Windows.Media.Brushes]::White
        $bold = $false

        for ($i = 0; $i -lt $parts.Count; $i++) {
            if ($parts[$i].Length -gt 0) {
                $run = New-Object System.Windows.Documents.Run($parts[$i])
                $run.Foreground = $foreground
                if ($bold) {
                    $run.FontWeight = [System.Windows.FontWeights]::Bold
                }
                [void]$textBlock.Inlines.Add($run)
            }

            if ($i -lt $matches.Count) {
                $codeText = $matches[$i].Value -replace "`e\[", "" -replace "m$", ""
                $codes = if ($codeText) {
                    $codeText -split ';' | ForEach-Object { [int]$_ }
                } else {
                    @(0)
                }

                foreach ($code in $codes) {
                    switch ($code) {
                        0  { $foreground = [System.Windows.Media.Brushes]::White; $bold = $false }
                        1  { $bold = $true }
                        22 { $bold = $false }

                        30 { $foreground = [System.Windows.Media.Brushes]::Black }
                        31 { $foreground = [System.Windows.Media.Brushes]::Red }
                        32 { $foreground = [System.Windows.Media.Brushes]::Green }
                        33 { $foreground = [System.Windows.Media.Brushes]::Yellow }
                        34 { $foreground = [System.Windows.Media.Brushes]::Blue }
                        35 { $foreground = [System.Windows.Media.Brushes]::Magenta }
                        36 { $foreground = [System.Windows.Media.Brushes]::Cyan }
                        37 { $foreground = [System.Windows.Media.Brushes]::White }
                        39 { $foreground = [System.Windows.Media.Brushes]::White }

                        90 { $foreground = [System.Windows.Media.Brushes]::DarkGray }
                        91 { $foreground = [System.Windows.Media.Brushes]::LightCoral }
                        92 { $foreground = [System.Windows.Media.Brushes]::LightGreen }
                        93 { $foreground = [System.Windows.Media.Brushes]::LightYellow }
                        94 { $foreground = [System.Windows.Media.Brushes]::LightBlue }
                        95 { $foreground = [System.Windows.Media.Brushes]::Violet }
                        96 { $foreground = [System.Windows.Media.Brushes]::LightCyan }
                        97 { $foreground = [System.Windows.Media.Brushes]::White }
                    }
                }
            }
        }

        [void]$listBox.Items.Add($textBlock)
    }

    if (Test-Path $Path) {
        $Path = (Resolve-Path $ShowFile).Path
        Get-Content $Path | ForEach-Object {
            Add-AnsiLine $_
        }
    }
    else {
        Add-AnsiLine "File not found: $Path"
    }

	# title setting code
    #$window.Title = $Path
    $window.Title = "Show-TextFile: $Path"
    $txtTitle.Text = $Path

    $btnClose.Add_Click({ $window.Close() })

    $window.Dispatcher.BeginInvoke([action]{
        $btnClose.Focus()
    }, [System.Windows.Threading.DispatcherPriority]::Input) | Out-Null

    $window.Add_PreviewKeyDown({
        param($sender, $e)
        if ($e.Key -eq 'Escape') {
            $window.Close()
        }
    })

    $window.ShowDialog() | Out-Null

}

#if ($MyInvocation.InvocationName -ne 'Show-TextFile') {
#    Show-TextFile -ShowFile $ShowFile
#}
