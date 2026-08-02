function touch {    # Create empty file in current folder
    param(
        [string]$filename
    )
    "" | Set-Content -Path $filename -Encoding utf8
    Write-Host "File $filename created ..." -ForegroundColor Green

}
