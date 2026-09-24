function Color-Text {    # Wrap text with ANSI color codes
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [ValidateSet('Default','Red','Green','Yellow','Blue','Cyan','Magenta','Gray')]
        [string]$Color = 'Default'
	)
	
    $prefix = switch ($Color) {
        'Red'     { $PSStyle.Foreground.Red }
        'Green'   { $PSStyle.Foreground.Green }
        'Yellow'  { $PSStyle.Foreground.Yellow }
        'Blue'    { $PSStyle.Foreground.Blue }
        'Cyan'    { $PSStyle.Foreground.Cyan }
        'Magenta' { $PSStyle.Foreground.Magenta }
        'Gray'    { $PSStyle.Foreground.BrightBlack }
        default   { '' }
    }

    $line = "{0}{1}{2}" -f `
        $prefix, $Text, $PSStyle.Reset

    Return $line
}