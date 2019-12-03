param (
    [Parameter(Mandatory=$true, ParameterSetName="computer", Position=0)]
    [String]$hostName = $null,

    [Parameter(Mandatory=$false, ParameterSetName="computer")]
    [Parameter(Mandatory=$false, ParameterSetName="protocol", Position=1)]
    [ValidateSet('TCP', 'UDP', 'ICMP')]
    [String]$protocol = $null,

    [Parameter(Mandatory=$true, ParameterSetName="protocol", Position=2)]
    [Parameter(Mandatory=$false, ParameterSetName="computer")]
    [int]$port = $null
)
[String]$lineProtocol = $null

switch($protocol) {
    "ICMP" { 
        $rawResult = psping $hostName -i -w 0 -i 0 -n 0
        Write-Host ICMP
        break;
    }
    "TCP" {
        Write-Host TCP
        $rawResult = psping ($hostName + ":" + $port) -t -w 0 -i 0 -n 0
    }
    "UDP" {
        Write-Host UDP
        $rawResult = psping ($hostName + ":" + $port) -u -w 0 -i 0 -n 0
    }
    default {
        Write-Host Default
        $rawResult = psping $hostName -i -w 0 -i 0 -n 0
    }
}
if(!$protocol) {
    $protocol = "ICMP"
    
}
$replyResult = $rawResult | Select-String Sent
$null = $replyResult.ToString() -match "Sent = (?<sent>.+), Received = (?<received>.+), Lost = (?<lost>.+) \("
$lineProtocol = "ping,host=" +$hostName + ",protocol=" + $protocol + ",port=" + $port + " " + "sent=" + $Matches.sent + ",received=" + $Matches.received + ",lost=" + $Matches.lost
$Matches = $null

$speed = $rawResult | Select-String Minimum
$null = $speed.ToString() -match "Minimum = (?<minimum>.+)ms, Maximum = (?<maximum>.+)ms, Average = (?<average>.+)ms"
$lineProtocol += ",minimum=" + $Matches.minimum + ",maximum=" + $Matches.maximum + ",average=" + $Matches.average
$Matches = $null

Write-Host $lineProtocol

# Invoke-WebRequest -Uri "http://localhost:8086/write?db=test" -Body '' -Method Post