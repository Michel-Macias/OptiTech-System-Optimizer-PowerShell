<#
.SYNOPSIS
    Limpia la caché de resolución de DNS.
.DESCRIPTION
    Ejecuta ipconfig /flushdns para borrar la caché de DNS, lo que puede
    solucionar problemas de conectividad o de acceso a sitios web.
#>
function Flush-DnsCache {
    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de DNS..." | Out-Null
    Write-Host -ForegroundColor White "`nLimpiando la caché de DNS (ipconfig /flushdns)..."
    try {
        $output = ipconfig /flushdns 2>&1
        # ipconfig puede devolver un código de salida no estándar, así que buscamos texto en la salida.
        if ($output -match 'correctamente') {
            $message = "Caché de DNS limpiada correctamente."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
        } else {
            throw $output
        }
    }
    catch {
        $errorMessage = "Ocurrió un error al limpiar la caché de DNS: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
    }
}
