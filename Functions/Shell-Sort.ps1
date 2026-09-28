# Schell-Metzner Sort algorithm
# Sort $Array
function Shell-Sort {	# Schell-Metzner Sort Routine
    param(
        [Parameter(Mandatory)]
        [object[]] $Array
    )

    $n = $Array.Count

#    write-host "Initial array: $($Array -join ", ")"

    # Generate Knuth's gap sequence:
    # 1, 4, 13, 40, 121, ...
    $gap = 1
    while ($gap -lt [math]::Floor($n / 3)) {
        $gap = 3 * $gap + 1
    }

    # Sort using decreasing gaps
    while ($gap -ge 1) {
        for ($i = $gap; $i -lt $n; $i++) {
            $temp = $Array[$i]
            $j = $i

            while ($j -ge $gap -and $Array[$j - $gap] -gt $temp) {
                $Array[$j] = $Array[$j - $gap]
#                write-host "A "$Array -join ", "
                $j -= $gap
            }

            $Array[$j] = $temp
        }

        $gap = [math]::Floor($gap / 3)
#        write-host "B "$Array -join ", "
    }

    return $Array
}