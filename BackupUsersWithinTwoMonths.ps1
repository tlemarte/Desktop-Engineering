$StartDate = (Get-Date)
$StartDate = $StartDate.AddDays(-60)
$StrSource ="C:\Users"
$StrTarget= "\\Backups\path\goes\here\$env:username\$env:computername"
Get-ChildItem $StrSource | Where-Object {($_.LastWriteTime.Date -ge $StartDate.Date)} | Copy-Item -Destination $StrTarget -Recurse