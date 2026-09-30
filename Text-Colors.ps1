# Text-Colors.ps1

$list = @(
		'Black'   
        'White'   
        'Red'    
        'Green'  
        'Yellow' 
        'Blue'   
        'Cyan'   
        'Magenta'
        'Gray'   
		'BrightBlack'
        'BrightWhite'   
        'BrightRed'     
        'BrightGreen'   
        'BrightYellow'  
        'BrightBlue'    
        'BrightCyan'    
        'BrightMagenta' 
        'BrightGray'    
)

    foreach ($color in $list) {
        Write-Host "`n$color"
        Color-Text -Text "This is $color text" -Color $color
        #Write-Host "$color" -ForegroundColor $color

    }
