<#
.SYNOPSIS
    Limpia los componentes de Windows desactualizados en la carpeta WinSxS.

.DESCRIPTION
    Ejecuta la herramienta DISM (Deployment Image Servicing and Management) con los parámetros
    /Online /Cleanup-Image /StartComponentCleanup para eliminar versiones antiguas de componentes
    de Windows. Esta operación puede liberar una cantidad significativa de espacio en disco.
    Es un proceso que puede tardar varios minutos.

.NOTES
    Requiere privilegios de administrador para ejecutarse correctamente.
#>
function Clear-WinSxSComponent {
    Write-Log -Level INFO -Message "Iniciando limpieza de componentes de Windows (WinSxS)..."
    Write-Log -Level INFO -Message "Ejecutando 'Dism.exe /online /Cleanup-Image /StartComponentCleanup'. Este proceso puede tardar bastante."

    try {
        # Se redirige la salida para un futuro análisis si fuera necesario, pero el log principal informa del inicio/fin.
        Dism.exe /online /Cleanup-Image /StartComponentCleanup | Out-Null
        Write-Log -Level INFO -Message "La limpieza de componentes de WinSxS ha finalizado correctamente."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error durante la limpieza de WinSxS con DISM: $_"
    }
}
