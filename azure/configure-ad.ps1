param(
    [Parameter(Mandatory=$true)]
    [string]$DomainName,

    [Parameter(Mandatory=$true)]
    [string]$SafeModePass,

    [Parameter(Mandatory=$true)]
    [string]$DomainNetbiosName = "CONTOSO"
)
Start-Transcript -Path "C:\ad-setup.log" -Force
# Pfade auf F:
$DatabasePath = "F:\NTDS"
$LogPath      = "F:\NTDS"
$SysvolPath   = "F:\SYSVOL"

# Passwort in SecureString umwandeln
$SafeModeSecure = ConvertTo-SecureString $SafeModePass -AsPlainText -Force

# Verzeichnisse anlegen
New-Item -Path $DatabasePath -ItemType Directory -Force | Out-Null
New-Item -Path $LogPath      -ItemType Directory -Force | Out-Null
New-Item -Path $SysvolPath   -ItemType Directory -Force | Out-Null

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