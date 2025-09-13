param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$true)]
    [string]$SafeModePass,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetbiosName = "CONTOSO"
)

Start-Transcript -Path "C:\ad-setup.log" -Force

Write-Host "=== Initialisiere Daten-Disk auf F: ==="
$disk = Get-Disk | Where-Object PartitionStyle -Eq 'RAW' | Sort-Object Number | Select-Object -First 1
if ($disk) {
    Initialize-Disk -Number $disk.Number -PartitionStyle MBR
    New-Partition -DiskNumber $disk.Number -UseMaximumSize -AssignDriveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel "ADData" -Confirm:$false
} else {
    Write-Host "Keine RAW-Disk gefunden. Überspringe Initialisierung."
}

Write-Host "=== Installiere AD DS Rolle ==="
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "=== Bereite Verzeichnisse vor ==="
$DatabasePath = "F:\NTDS"
$LogPath      = "F:\NTDS"
$SysvolPath   = "F:\SYSVOL"

New-Item -Path $DatabasePath -ItemType Directory -Force | Out-Null
New-Item -Path $LogPath      -ItemType Directory -Force | Out-Null
New-Item -Path $SysvolPath   -ItemType Directory -Force | Out-Null

Write-Host "=== Promote zum Domain Controller ==="
$SafeModeSecure = ConvertTo-SecureString $SafeModePass -AsPlainText -Force

Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -SafeModeAdministratorPassword $SafeModeSecure `
    -DatabasePath $DatabasePath `
    -LogPath $LogPath `
    -SysvolPath $SysvolPath `
    -InstallDns `
    -Force:$true `
    -NoRebootOnCompletion:$false

Stop-Transcript
