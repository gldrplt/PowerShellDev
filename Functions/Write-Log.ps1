function Write-Log {    # Write log message with optional color and timestamp
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Default','Red','Green','Yellow','Blue','Cyan','Magenta','Gray')]
        [string]$Color = 'Default',

        [string]$LogFile = '.\log.txt',
    
		[string]$TimeStampFormat
	
	)
	
    # Generate Timestamp if TimeStampFormat is provided
    $timestamp = $null
	if ($TimeStampFormat){
		$timestamp = Get-Date -Format $TimeStampFormat
	}
	
    # Check if valid color is provided
    $prefix = switch ($Color) {
        'Red'     { $PSStyle.Foreground.Red }
        'Green'   { $PSStyle.Foreground.Green }
        'Yellow'  { $PSStyle.Foreground.Yellow }
        'Blue'    { $PSStyle.Foreground.Blue }
        'Cyan'    { $PSStyle.Foreground.Cyan }
        'Magenta' { $PSStyle.Foreground.Magenta }
        'Gray'    { $PSStyle.Foreground.BrightBlack }
        default   { $false }
    }

    if ($prefix) {      # If a color is specified, format the log line with color
        $line = "{0}{1} {2}{3}" -f `
            $prefix, $timestamp, $Message, $PSStyle.Reset
        }
    else {              # If no color is specified, format the log line without color
        $line = "{0} {1}" -f `
        $timestamp, $Message
    }
    Add-Content -Path $LogFile -Value $line
}