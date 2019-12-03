$csvs = Import-Csv -Path "C:\PowerShell\PingMonitor\static\servers.csv"

foreach ($csv in $csvs) {
    Start-Job -FilePath C:\PowerShell\PingMonitor\scriptBlock\startPsPing.ps1 -ArgumentList $csv.hostName, $csv.hostIP
}