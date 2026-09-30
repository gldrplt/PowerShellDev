# Debug-Function.ps1

[CmdletBinding()]
param()

Clear-Host
Write-Host "Debug PowerShell Script`nSet breakpoint(s) in function being debugged`n`n- Select Function File`n" -ForegroundColor Cyan
# ------------------------------------------------------------
# Get the function file
# ------------------------------------------------------------

$file = Select-File -Title "Select a PowerShell Function file" -Filter "PowerShell Script (*.ps1)|*.ps1"
if ( -not $file ) {
    Write-Host "No function file selected." -ForegroundColor Red
    return
}

$FunctionFile = $file.FullName

# ------------------------------------------------------------
# Find function definitions in the file
# ------------------------------------------------------------

$FunctionDefinitions = @(
    Select-String `
        -Path $FunctionFile `
        -Pattern '^\s*function\s+([a-zA-Z0-9_-]+)' |
    ForEach-Object {
        $_.Matches[0].Groups[1].Value
    }
)

if ($FunctionDefinitions.Count -eq 0) {
    throw "No function definition found in $FunctionFile"
}

# ------------------------------------------------------------
# Select the function
# ------------------------------------------------------------

if ($FunctionDefinitions.Count -eq 1) {

    $FunctionName = $FunctionDefinitions[0]

}
else {
    $FunctionDefinitions = $FunctionDefinitions | Sort-Object
    $cnt = $FunctionDefinitions.Count
    Write-Host "`n$cnt Functions found in $FunctionFile`:" -ForegroundColor Cyan

    for ($i = 0; $i -lt $FunctionDefinitions.Count; $i++) {
        Write-Host "  $($i + 1). $($FunctionDefinitions[$i])"
    }

    do {
        $choice = Read-Host "`nSelect function"

        $index = 0
        $valid = [int]::TryParse($choice, [ref]$index)

        if ($valid) {
            $index--
            $valid = (
                $index -ge 0 -and
                $index -lt $FunctionDefinitions.Count
            )
        }

        if (-not $valid) {
            Write-Host "Invalid selection." -ForegroundColor Red
        }

    } until ($valid)

    $FunctionName = $FunctionDefinitions[$index]
}

# ------------------------------------------------------------
# Remove existing function definition
# Load the function
# ------------------------------------------------------------
Remove-Item "Function:\$FunctionName" -ErrorAction SilentlyContinue
. $FunctionFile

$Command = Get-Command $FunctionName -CommandType Function -ErrorAction Stop

Write-Host "`nFunction: $FunctionName" -ForegroundColor Cyan
Write-Host "File:     $FunctionFile`n"

# ------------------------------------------------------------
# Collect parameter values
# ------------------------------------------------------------

$Arguments = @{}

foreach ($Parameter in $Command.Parameters.Values) {

    $Name = $Parameter.Name
    $Type = $Parameter.ParameterType

    # Skip common PowerShell common parameters
    if ($Parameter.IsDynamic -or
        $Name -in @(
            'Verbose',
            'Debug',
            'ErrorAction',
            'ErrorVariable',
            'WarningAction',
            'WarningVariable',
            'InformationAction',
            'InformationVariable',
            'OutVariable',
            'OutBuffer',
            'ProgressAction',
            'PipelineVariable'
        )) {
        continue
    }

    # --------------------------------------------------------
    # Switch parameters
    # --------------------------------------------------------

    if ($Type -eq [switch]) {

        do {
            $Answer = Read-Host "$Name [switch] (Y/N)"

            if ([string]::IsNullOrWhiteSpace($Answer)) {
                $Answer = "N"
            }

            $ValidAnswer = $Answer -match '^(y|yes|n|no)$'

            if (-not $ValidAnswer) {
                Write-Host "Enter Y or N." -ForegroundColor Yellow
            }

        } until ($ValidAnswer)

        if ($Answer -match '^(y|yes)$') {
            $Arguments[$Name] = $true
        }

        continue
    }

    # --------------------------------------------------------
    # Determine whether parameter is mandatory
    # --------------------------------------------------------

    $IsMandatory = $false

    foreach ($Attribute in $Parameter.Attributes) {
        if ($Attribute -is [System.Management.Automation.ParameterAttribute]) {
            if ($Attribute.Mandatory) {
                $IsMandatory = $true
                break
            }
        }
    }

    # --------------------------------------------------------
    # Find default value
    # --------------------------------------------------------

    $DefaultValue = $null

    foreach ($Attribute in $Parameter.Attributes) {
        if ($Attribute -is [System.Management.Automation.PSDefaultValueAttribute]) {
            $DefaultValue = $Attribute.Value
            break
        }
    }

    # --------------------------------------------------------
    # Build prompt
    # --------------------------------------------------------

    $Prompt = "$Name [$($Type.Name)]"

    if ($IsMandatory) {
        $Prompt += " [required]"
    }

    if ($null -ne $DefaultValue) {
        $Prompt += " [default: $DefaultValue]"
    }

    $Prompt += ":"

    # --------------------------------------------------------
    # Get parameter value
    # --------------------------------------------------------

    do {

        $Value = Read-Host $Prompt

        # Use default
        if ([string]::IsNullOrWhiteSpace($Value) -and
            $null -ne $DefaultValue) {

            $Value = $DefaultValue
        }

        # Required parameter
        if ([string]::IsNullOrWhiteSpace($Value) -and $IsMandatory) {
            Write-Host "A value is required." -ForegroundColor Yellow
            continue
        }

        break

    } while ($true)

    # --------------------------------------------------------
    # Optional parameter left blank
    # --------------------------------------------------------

    if ([string]::IsNullOrWhiteSpace($Value)) {
        continue
    }

    # --------------------------------------------------------
    # Convert value to declared parameter type
    # --------------------------------------------------------

    try {

        switch ($Type.FullName) {

            'System.String' {
                $ConvertedValue = [string]$Value
            }

            'System.Int32' {
                $ConvertedValue = [int]$Value
            }

            'System.Int64' {
                $ConvertedValue = [long]$Value
            }

            'System.Int16' {
                $ConvertedValue = [short]$Value
            }

            'System.Double' {
                $ConvertedValue = [double]$Value
            }

            'System.Decimal' {
                $ConvertedValue = [decimal]$Value
            }

            'System.Single' {
                $ConvertedValue = [single]$Value
            }

            'System.Boolean' {
                $ConvertedValue = [bool]::Parse($Value)
            }

            'System.DateTime' {
                $ConvertedValue = [datetime]$Value
            }

            default {
                $ConvertedValue = $Value -as $Type

                if ($null -eq $ConvertedValue -and $Type -ne [string]) {
                    throw "Unable to convert value."
                }
            }
        }

        $Arguments[$Name] = $ConvertedValue

    }
    catch {
        throw "Cannot convert '$Value' to [$($Type.Name)] for parameter -$Name"
    }
}

# ------------------------------------------------------------
# Display invocation
# ------------------------------------------------------------

Write-Host "`nCalling $FunctionName..." -ForegroundColor Cyan

if ($Arguments.Count -gt 0) {
    Write-Host "Parameters:" -ForegroundColor DarkGray

    foreach ($Key in $Arguments.Keys) {
        Write-Host "  -$Key = $($Arguments[$Key])" -ForegroundColor DarkGray
    }
}

Write-Host ""

# ------------------------------------------------------------
# Invoke function
# ------------------------------------------------------------

& $FunctionName @Arguments

Write-Host "Debug-Function completed.`n" -ForegroundColor Cyan

