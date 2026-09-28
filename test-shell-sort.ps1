if (Test-Path Function:\Shell-Sort) {
    Remove-Item Function:\Shell-Sort
}
. .\Shell-Sort.ps1
$a = 8, 5, 3, 9, 1, 6, 2, 7, 4
$b = $a.clone()
$b = $a + $a    # combine two arrays
shell-sort $b

