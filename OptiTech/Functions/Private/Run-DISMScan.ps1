<#
.SYNOPSIS
    Ejecuta la herramienta DISM para reparar la imagen de Windows.
.DESCRIPTION
    Invoca a dism.exe para realizar una comprobaciÃ³n de estado y reparaciÃ³n
    de la imagen del sistema operativo.
#>
function Run-DISMScan {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para ejecutar un escaneo DISM."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando escaneo DISM para comprobar la salud de la imagen del sistema..." | Out-Null
    Write-Host -ForegroundColor White "\nIniciando escaneo DISM para comprobar la salud de la imagen del sistema..."
    Write-Host -ForegroundColor Yellow "Este proceso puede tardar varios minutos y no debe ser interrumpido."

    try {
        if ($pscmdlet.ShouldProcess("Imagen del Sistema", "Escanear y Restaurar Salud con DISM")) {
            Write-Host -ForegroundColor White "- Ejecutando DISM /Online /Cleanup-Image /ScanHealth..."
            Dism.exe /Online /Cleanup-Image /ScanHealth | Out-Null
            Write-Log -Level INFO -Message "DISM ScanHealth completado." | Out-Null

            Write-Host -ForegroundColor White "- Ejecutando DISM /Online /Cleanup-Image /RestoreHealth..."
            Dism.exe /Online /Cleanup-Image /RestoreHealth | Out-Null
            $message = "Escaneo y reparación con DISM completados."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"
        }
    } catch {
        $errorMessage = "Ocurrió un error durante el escaneo DISM."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}

