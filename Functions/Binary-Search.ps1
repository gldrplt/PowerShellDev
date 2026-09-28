function Binary-Search {	# Binary Search Routine
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]] $Array,

        [Parameter(Mandatory)]
        [object] $Value
    )

    $low  = 0
    $high = $Array.Count - 1

    while ($low -le $high) {
        $mid = $low + [math]::Floor(($high - $low) / 2)

        if ($Array[$mid] -eq $Value) {
            return $mid
        }

        if ($Array[$mid] -lt $Value) {
            $low = $mid + 1
        }
        else {
            $high = $mid - 1
        }
    }

    return -1
}