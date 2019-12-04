param (
    [Parameter(Mandatory=$true, Position=0)]
    [String]$vmName = $null,

    [Parameter(Mandatory=$true, ParameterSetName="computer", Position=1)]
    [String]$hostIP = $null,

    [Parameter(Mandatory=$false, ParameterSetName="computer")]
    [Parameter(Mandatory=$false, ParameterSetName="protocol", Position=2)]
    [ValidateSet('TCP', 'ICMP')]
    [String]$protocol = $null,

    [Parameter(Mandatory=$true, ParameterSetName="protocol", Position=3)]
    [Parameter(Mandatory=$false, ParameterSetName="computer")]
    [int]$port = $null
)

$influxConfig = Get-Content -Raw -Path "D:\PowerShell\PingMonitor\static\influx.json" | ConvertFrom-Json
$influxURI = "http://" + $influxConfig.host + ":" + $influxConfig.port + "/" + "write?db=" + $influxConfig.database
[int32]$batchSize = $influxConfig.batchSize

while($true){
    $logDate = $null
    $logDate = [String]([double](Get-Date -UFormat %s) * 100000) + "0" + "000"
    switch($protocol) {
        "ICMP" { 
            $rawResult = psping $hostIP -i -w 0 -i 0 -n 0
            break;
        }
        "TCP" {
            $rawResult = psping ($hostIP + ":" + $port) -t -w 0 -i 0 -n 0
        }
        default {
            $rawResult = psping $hostIP -i -w 0 -i 0 -n 0
        }
    }
    if(!$protocol) {
        $protocol = "ICMP"
    
    }
    $replyResult = $rawResult | Select-String Sent
    $null = $replyResult.ToString() -match "Sent = (?<sent>.+), Received = (?<received>.+), Lost = (?<lost>.+) \("
    $lineProtocol = "ping,host=" +$vmName + ",host_ip=" + $hostIP + ",protocol=" + $protocol + ",port=" + $port + " " + "sent=" + $Matches.sent + ",received=" + $Matches.received + ",lost=" + $Matches.lost
    $Matches = $null

    $speed = $rawResult | Select-String Minimum
    $null = $speed.ToString() -match "Minimum = (?<minimum>.+)ms, Maximum = (?<maximum>.+)ms, Average = (?<average>.+)ms"
    $lineProtocol += ",minimum=" + $Matches.minimum + ",maximum=" + $Matches.maximum + ",average=" + $Matches.average + " " + $logDate
    $Matches = $null
    
    $batchLineProtocol += $lineProtocol
    Write-Host $batchLineProtocol.Count
    if($batchLineProtocol.Count -eq $batchSize) {
        $null = Invoke-WebRequest -Uri $influxURI -Body ($batchLineProtocol -join "`n") -Method Post -InformationAction SilentlyContinue
        $batchLineProtocol = $null
    }
    Start-Sleep -Seconds 1 
}