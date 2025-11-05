<#
.SYNOPSIS
    Ejecuta el Comprobador de archivos de sistema (SFC).
.DESCRIPTION
    Invoca a sfc.exe con el argumento /scannow para verificar la integridad
    de los archivos de sistema y repararlos si es necesario.
#>
function Run-SFCScan {
    Write-Log -Level INFO -Message "Iniciando ejecución de SFC..." | Out-Null
    Write-Host -ForegroundColor Yellow "`nEjecutando 'sfc /scannow'..."
    Write-Host -ForegroundColor Yellow "Este proceso puede tardar varios minutos y requiere privilegios de Administrador."
    Write-Host -ForegroundColor White "El sistema puede parecer que no responde, por favor, ten paciencia."

    try {
        # La salida de SFC es útil, así que la pasamos directamente a la consola.
        sfc.exe /scannow
        if ($LASTEXITCODE -ne 0) {
            throw "sfc.exe falló con código de salida $LASTEXITCODE."
        }
        $message = "'sfc /scannow' completado."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "`n✔ $message"
    }
    catch {
        $errorMessage = "Ocurrió un error durante la ejecución de SFC: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "`n❌ $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}
