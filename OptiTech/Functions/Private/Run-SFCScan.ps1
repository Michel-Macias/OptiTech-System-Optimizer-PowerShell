<#
.SYNOPSIS
    Ejecuta el Comprobador de archivos de sistema (SFC).
.DESCRIPTION
    Invoca a sfc.exe con el argumento /scannow para verificar la integridad
    de los archivos de sistema y repararlos si es necesario.
#>
function Run-SFCScan {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para ejecutar un escaneo SFC."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando escaneo SFC (System File Checker)..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando escaneo SFC (System File Checker)..."
    Write-Host -ForegroundColor Yellow "Este proceso puede tardar varios minutos y no debe ser interrumpido."

    try {
        if ($pscmdlet.ShouldProcess("Archivos del Sistema", "Escanear y reparar con SFC")) {
            sfc.exe /scannow | Out-Null
            $message = "Escaneo SFC completado. Revisa el archivo de log de CBS para mas detalles si se encontraron problemas."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"
        }
    } catch {
        $errorMessage = "Ocurrio un error durante el escaneo SFC."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "Asegurate de estar ejecutando el script como Administrador."
    }
}

