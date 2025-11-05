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
    Write-Log -Level INFO -Message "Iniciando limpieza de componentes de Windows (WinSxS)..." | Out-Null
    
    Write-Host -ForegroundColor Yellow "`nIniciando limpieza de componentes de Windows (WinSxS)..."
    Write-Host -ForegroundColor Yellow "Esta operación puede tardar varios minutos y requiere privilegios de Administrador."
    Write-Host -ForegroundColor White "Ejecutando 'Dism.exe /online /Cleanup-Image /StartComponentCleanup'..."

    try {
        # Se redirige la salida para un futuro análisis si fuera necesario.
        $output = Dism.exe /online /Cleanup-Image /StartComponentCleanup 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Dism.exe falló con código de salida $LASTEXITCODE. Salida: $output"
        }
        $message = "La limpieza de componentes de WinSxS ha finalizado correctamente."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "`n✔ $message"
    }
    catch {
        $errorMessage = "Ocurrió un error durante la limpieza de WinSxS con DISM: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "`n❌ $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}
