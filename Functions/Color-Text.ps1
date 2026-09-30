function Color-Text {    # Wrap text with ANSI color codes
    param(
        [Parameter(Mandatory)]
        [string]$Text,

        [Parameter(Mandatory)]
        # [ValidateSet('Default','Red','Green','Yellow','Blue','Cyan','Magenta','Gray')]
        [string]$Color = 'Default'
	)
	
    $prefix = switch ($Color) {
		'Black'   { $PSStyle.Foreground.Black }
        'White'   { $PSStyle.Foreground.White }
        'Red'     { $PSStyle.Foreground.Red }
        'Green'   { $PSStyle.Foreground.Green }
        'Yellow'  { $PSStyle.Foreground.Yellow }
        'Blue'    { $PSStyle.Foreground.Blue }
        'Cyan'    { $PSStyle.Foreground.Cyan }
        'Magenta' { $PSStyle.Foreground.Magenta }
        'Gray'    { $PSStyle.Foreground.BrightBlack }

        'BrightBlack'   { $PSStyle.Foreground.BrightBlack }
        'BrightWhite'   { $PSStyle.Foreground.BrightWhite }
        'BrightRed'     { $PSStyle.Foreground.BrightRed }
        'BrightGreen'   { $PSStyle.Foreground.BrightGreen }
        'BrightYellow'  { $PSStyle.Foreground.BrightYellow }
        'BrightBlue'    { $PSStyle.Foreground.BrightBlue }
        'BrightCyan'    { $PSStyle.Foreground.BrightCyan }
        'BrightMagenta' { $PSStyle.Foreground.BrightMagenta }
        'BrightGray'    { $PSStyle.Foreground.BrightBlack }

        default   { '' }
    }

    $line = "{0}{1}{2}" -f `
        $prefix, $Text, $PSStyle.Reset

    Return $line
}