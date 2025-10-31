<#
.SYNOPSIS
    Limpia la caché de descargas de Windows Update.
.DESCRIPTION
    Detiene el servicio de Windows Update, elimina los archivos de la caché de descargas
    y reinicia el servicio. Esto puede solucionar problemas con Windows Update y liberar espacio.
#>
function Clear-UpdateCache {
    Write-Log -Level INFO -Message "Limpiando la caché de Windows Update..."
    $path = "$env:SystemRoot\SoftwareDistribution\Download"

    Write-Log -Level INFO -Message "Deteniendo el servicio de Windows Update (wuauserv)..."
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue

    if (Test-Path -Path $path) {
        Write-Log -Level INFO -Message "Eliminando archivos de $path..."
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Level INFO -Message "Archivos de la caché de Windows Update eliminados."
    } else {
        Write-Log -Level WARNING -Message "El directorio de la caché de Windows Update no se encontró en $path."
    }

    Write-Log -Level INFO -Message "Iniciando el servicio de Windows Update (wuauserv)..."
    Start-Service -Name wuauserv
    Write-Log -Level INFO -Message "Limpieza de caché de Windows Update completada."
}
