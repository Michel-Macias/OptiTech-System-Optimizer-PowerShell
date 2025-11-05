<#
.SYNOPSIS
    Renueva la concesión de la dirección IP.
.DESCRIPTION
    Ejecuta ipconfig /renew para solicitar una nueva dirección IP al servidor DHCP.
    Útil para solucionar problemas de conectividad de red.
#>
function Renew-IpAddress {
    Write-Log -Level INFO -Message "Renovando la dirección IP (ipconfig /renew)..."
    try {
        ipconfig /renew
        Write-Log -Level INFO -Message "Dirección IP renovada correctamente."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error al renovar la dirección IP: $_"
    }
}
