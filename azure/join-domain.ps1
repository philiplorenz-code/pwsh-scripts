param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$true)]
    [string]$DomainJoinUser,   # z.B. "CONTOSO\Administrator"

    [Parameter(Mandatory=$true)]
    [string]$DomainJoinPassword,

    [Parameter(Mandatory=$true)]
    [string]$DnsServer   # IP des DC
)

Start-Transcript -Path "C:\domain-join.log" -Force

Write-Host "=== Setze DNS-Server auf $DnsServer ==="
$nic = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceIndex $nic.InterfaceIndex -ServerAddresses $DnsServer

Write-Host "=== Warte kurz, damit DNS übernommen wird ==="
Start-Sleep -Seconds 10

Write-Host "=== Konvertiere Passwort in SecureString ==="
$secpasswd = ConvertTo-SecureString $DomainJoinPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($DomainJoinUser, $secpasswd)

Write-Host "=== Domain Join starten ==="
Add-Computer `
    -DomainName $DomainName `
    -Credential $credential `
    -Force `
    -ErrorAction Stop

Write-Host "=== Neustart auslösen ==="
Restart-Computer -Force

Stop-Transcript
