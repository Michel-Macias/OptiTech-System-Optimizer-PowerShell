<#
.SYNOPSIS
    Ejecuta la herramienta DISM para reparar la imagen de Windows.
.DESCRIPTION
    Invoca a dism.exe para realizar una comprobación de estado y reparación
    de la imagen del sistema operativo.
#>
function Run-DISMScan {
    Write-Log -Level INFO -Message "Iniciando ejecución de DISM..." | Out-Null
    Write-Host -ForegroundColor Yellow "`nEjecutando 'DISM /Online /Cleanup-Image /RestoreHealth'..."
    Write-Host -ForegroundColor Yellow "Este proceso puede tardar varios minutos y requiere privilegios de Administrador."
    Write-Host -ForegroundColor White "El sistema puede parecer que no responde, por favor, ten paciencia."

    try {
        # La salida de DISM es útil, así que la pasamos directamente a la consola.
        dism.exe /online /cleanup-image /restorehealth
        if ($LASTEXITCODE -ne 0) {
            throw "dism.exe falló con código de salida $LASTEXITCODE."
        }
        $message = "'DISM /Online /Cleanup-Image /RestoreHealth' completado."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "`n✔ $message"
    }
    catch {
        $errorMessage = "Ocurrió un error durante la ejecución de DISM: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "`n❌ $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}
