<#
.SYNOPSIS
    Limpia la caché de descargas de Windows Update.
.DESCRIPTION
    Detiene el servicio de Windows Update, elimina los archivos de la caché de descargas
    y reinicia el servicio. Esto puede solucionar problemas con Windows Update y liberar espacio.
#>
function Clear-UpdateCache {
    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de Windows Update..." | Out-Null
    $path = "$env:SystemRoot\SoftwareDistribution\Download"

    Write-Host -ForegroundColor White "`nDeteniendo el servicio de Windows Update (wuauserv)..."
    Write-Log -Level INFO -Message "Deteniendo el servicio de Windows Update (wuauserv)..." | Out-Null
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    # Pequeña pausa para asegurar que el servicio se detiene antes de borrar archivos.
    Start-Sleep -Seconds 2

    if (Test-Path -Path $path) {
        Write-Host -ForegroundColor White "Eliminando archivos de la caché de Windows Update..."
        Write-Log -Level INFO -Message "Eliminando archivos de $path..." | Out-Null
        # Usar un método más robusto para el borrado
        Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Level INFO -Message "Archivos de la caché de Windows Update eliminados." | Out-Null
    } else {
        $warningMessage = "El directorio de la caché de Windows Update no se encontró en $path."
        Write-Log -Level WARNING -Message $warningMessage | Out-Null
        Write-Host -ForegroundColor Yellow "- $warningMessage"
    }

    Write-Host -ForegroundColor White "Iniciando el servicio de Windows Update (wuauserv)..."
    Write-Log -Level INFO -Message "Iniciando el servicio de Windows Update (wuauserv)..." | Out-Null
    Start-Service -Name wuauserv

    $finalMessage = "Limpieza de caché de Windows Update completada."
    Write-Log -Level INFO -Message $finalMessage | Out-Null
    Write-Host -ForegroundColor Green "`n✔ $finalMessage"
}
