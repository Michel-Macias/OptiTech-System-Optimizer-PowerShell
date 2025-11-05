<#
.SYNOPSIS
    Renueva la concesión de la dirección IP.
.DESCRIPTION
    Ejecuta ipconfig /renew para solicitar una nueva dirección IP al servidor DHCP.
    Útil para solucionar problemas de conectividad de red.
#>
function Renew-IpAddress {
    Write-Log -Level INFO -Message "Iniciando renovación de la dirección IP..." | Out-Null
    Write-Host -ForegroundColor White "`nRenovando la dirección IP (ipconfig /renew)..."
    try {
        # ipconfig puede ser verboso, capturamos la salida para no mostrarla a menos que haya un error.
        $output = ipconfig /renew 2>&1
        if ($LASTEXITCODE -eq 0) {
            $message = "Dirección IP renovada correctamente."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
            # Mostramos la nueva configuración de la IP como información útil.
            ipconfig | Out-String | Write-Host
        } else {
            throw $output
        }
    }
    catch {
        $errorMessage = "Ocurrió un error al renovar la dirección IP: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
    }
}
