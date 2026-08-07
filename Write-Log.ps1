function Write-Log {    # Write log message with optional color and timestamp
    param(
        [Parameter(Mandatory)]
        [string]$Message,

        [ValidateSet('Default','Red','Green','Yellow','Blue','Cyan','Magenta','Gray')]
        [string]$Color = 'Default',

        [string]$LogFile = '.\log.txt',
    
		[string]$TimeStampFormat
	
	)
	
    $timestamp = $null
	if ($TimeStampFormat){
		$timestamp = Get-Date -Format $TimeStampFormat
	}
	
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

    $line = "{0}{1}{2}{3}" -f `
        $timestamp, $prefix, $Message, $PSStyle.Reset

    Add-Content -Path $LogFile -Value $line
}