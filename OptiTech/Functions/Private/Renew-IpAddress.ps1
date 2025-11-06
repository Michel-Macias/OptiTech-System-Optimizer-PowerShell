<#
.SYNOPSIS
    Renueva la concesiÃ³n de la direcciÃ³n IP.
.DESCRIPTION
    Ejecuta ipconfig /renew para solicitar una nueva direcciÃ³n IP al servidor DHCP.
    Ãštil para solucionar problemas de conectividad de red.
#>
function Renew-IpAddress {
    [CmdletBinding()]
    param()

    Write-Log -Level INFO -Message "Iniciando liberaciÃ³n y renovaciÃ³n de la direcciÃ³n IP..." | Out-Null
    Write-Host -ForegroundColor White "`nLiberando y renovando la direcciÃ³n IP..."

    try {
        Write-Host -ForegroundColor White "- Liberando la concesiÃ³n de IP actual (ipconfig /release)..."
        ipconfig /release | Out-Null
        Write-Log -Level INFO -Message "IP liberada." | Out-Null

        Write-Host -ForegroundColor White "- Renovando la concesiÃ³n de IP (ipconfig /renew)..."
        ipconfig /renew | Out-Null
        Write-Log -Level INFO -Message "IP renovada." | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $message = "La direcciÃ³n IP ha sido liberada y renovada con Ã©xito."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"
        } else {
            $errorMessage = "El comando ipconfig finalizÃ³ con un cÃ³digo de error. Es posible que la renovaciÃ³n no haya sido exitosa."
            Write-Log -Level WARNING -Message $errorMessage | Out-Null
            Write-Host -ForegroundColor Yellow "(AVISO) $errorMessage"
        }
    } catch {
        $errorMessage = "OcurriÃ³ un error durante el proceso de liberaciÃ³n/renovaciÃ³n de IP."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
    }
}

