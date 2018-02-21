param (
    [string] $dir = $(throw "-root is required.")
)

$rootDir= Get-ChildItem -Path $dir

foreach ($item in $rootDir) {
    #Write-Output $item.Name
    # Get Last backup file
    $db=Get-ChildItem -Path $item.FullName | Sort-Object LastAccessTime -Descending | Select-Object -First 1 |Select-Object $_.Name

    if ($db.Extension -notmatch ".bak")
    {
        continue
    }

    #Write-Output $db.FullName
    $sql = @"
    USE [master];
    alter database $($item.Name) set offline with rollback immediate 
    RESTORE DATABASE [$($item.Name)] FROM  DISK = N'$($db.FullName)' WITH  FILE = 1,  NOUNLOAD,  STATS = 5
    alter database $($item.Name) set online with rollback immediate
"@

    Write-Output "$sql"
    Invoke-Sqlcmd -Query "$sql" -ServerInstance "."
}