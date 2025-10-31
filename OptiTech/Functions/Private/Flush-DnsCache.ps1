<#
.SYNOPSIS
    Limpia la caché de resolución de DNS.
.DESCRIPTION
    Ejecuta ipconfig /flushdns para borrar la caché de DNS, lo que puede
    solucionar problemas de conectividad o de acceso a sitios web.
#>
function Flush-DnsCache {
    Write-Log -Level INFO -Message "Limpiando la caché de DNS (ipconfig /flushdns)..."
    try {
        ipconfig /flushdns
        Write-Log -Level INFO -Message "Caché de DNS limpiada correctamente."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error al limpiar la caché de DNS: $_"
    }
}
