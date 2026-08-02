#	Show-TextFile function
#param(
#    [string]$ShowFile
#)

function Show-TextFile {	# Show text file in scrollable window

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
        FontSize="14">
    
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
            Foreground="DarkBlue"
            TextWrapping="Wrap"
            Margin="0,0,0,10"/>

    <ListBox Name="listBox"
            Grid.Row="1"
            FontFamily="Consolas"
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


    if (Test-Path $Path) {
		$Path = (Resolve-Path $ShowFile).Path
        Get-Content $Path | ForEach-Object {
            [void]$listBox.Items.Add($_)
        }
    }
    else {
        $listBox.Items.Add("File not found: $Path")
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
