$csvs = Import-Csv -Path "D:\PowerShell\PingMonitor\static\servers.csv"

foreach ($csv in $csvs) {
    Start-Job -FilePath D:\PowerShell\PingMonitor\src\scriptBlock\startPing.ps1 -ArgumentList $csv.hostName, $csv.hostIP, $csv.protocol, $csv.port
}