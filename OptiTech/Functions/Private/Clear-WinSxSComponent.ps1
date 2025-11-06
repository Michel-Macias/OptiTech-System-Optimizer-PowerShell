<#
.SYNOPSIS
    Limpia los componentes de Windows desactualizados en la carpeta WinSxS.

.DESCRIPTION
    Ejecuta la herramienta DISM (Deployment Image Servicing and Management) con los parametros
    /Online /Cleanup-Image /StartComponentCleanup para eliminar versiones antiguas de componentes
    de Windows. Esta operacion puede liberar una cantidad significativa de espacio en disco.
    Es un proceso que puede tardar varios minutos.

.NOTES
    Requiere privilegios de administrador para ejecutarse correctamente.
#>
function Clear-WinSxSComponent {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para realizar una limpieza del almacen de componentes (WinSxS)."
        Write-Log -Level ERROR -Message $errorMessage
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $message = "La limpieza del almacen de componentes (WinSxS) puede tardar mucho tiempo y podria requerir reinicios. Desea continuar?"
    Write-Host -ForegroundColor Yellow "`n$message"
    $confirmation = Read-Host "Escribe 'SI' para confirmar."

    if ($confirmation -ne 'SI') {
        $cancelMessage = "Operacion cancelada por el usuario."
        Write-Log -Level INFO -Message $cancelMessage
        Write-Host -ForegroundColor Yellow "$cancelMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando limpieza del almacen de componentes (WinSxS)..."
    Write-Host -ForegroundColor White "`nIniciando analisis y limpieza del almacen de componentes (WinSxS)..."

    try {
        Write-Host -ForegroundColor White "- Analizando el almacen de componentes... (Esto puede tardar)"
        Dism.exe /Online /Cleanup-Image /AnalyzeComponentStore | Out-Null
        Write-Log -Level INFO -Message "Analisis de WinSxS completado."

        if ($pscmdlet.ShouldProcess("Almacen de Componentes", "Limpiar con reseteo de base")) {
            Write-Host -ForegroundColor White "- Iniciando la limpieza... (Esto puede tardar mucho tiempo)"
            Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-Null
            $successMessage = "Limpieza del almacen de componentes (WinSxS) completada con exito."
            Write-Log -Level INFO -Message $successMessage
            Write-Host -ForegroundColor Green "(OK) $successMessage"
        }
    } catch {
        $errorMessage = "Ocurrio un error durante la limpieza de WinSxS."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_"
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "Asegurate de estar ejecutando el script como Administrador."
    }
}
