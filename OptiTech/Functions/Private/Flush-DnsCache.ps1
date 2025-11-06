<#
.SYNOPSIS
    Limpia la caché de resolución de DNS.
.DESCRIPTION
    Ejecuta ipconfig /flushdns para borrar la caché de DNS, lo que puede
    solucionar problemas de conectividad o de acceso a sitios web.
#>
function Flush-DnsCache {
    [CmdletBinding()]
    param()

    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de DNS..." | Out-Null
    Write-Host -ForegroundColor White "`nLimpiando la caché de resolución de DNS..."

    try {
        $output = ipconfig /flushdns
        Write-Log -Level INFO -Message ("Resultado de ipconfig /flushdns: `n" + ($output | Out-String)) | Out-Null

        if ($output -match 'correctamente') {
            $message = "La caché de resolución de DNS se ha vaciado correctamente."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"
        } else {
            $errorMessage = "No se pudo confirmar la limpieza de la caché de DNS. El resultado fue inesperado."
            Write-Log -Level WARNING -Message ("$errorMessage Resultado: `n" + ($output | Out-String)) | Out-Null
            Write-Host -ForegroundColor Yellow "(AVISO) $errorMessage"
        }
    } catch {
        $errorMessage = "Ocurrió un error al ejecutar ipconfig /flushdns."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
    }
}

