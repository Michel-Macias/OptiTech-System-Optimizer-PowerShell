<#
.SYNOPSIS
    Elimina todos los puntos de restauración y las copias sombra (shadow copies).
.DESCRIPTION
    Ejecuta el comando vssadmin para eliminar todas las copias sombra, lo que incluye
    los puntos de restauración del sistema. Esta acción es irreversible y libera
    una cantidad significativa de espacio en disco.
#>
function Remove-SystemRestorePoints {
    Write-Log -Level WARNING -Message "Esta acción eliminará TODOS los puntos de restauración del sistema y las copias sombra."
    Write-Log -Level WARNING -Message "No podrás revertir el sistema a un estado anterior. Esta acción es IRREVERSIBLE."
    
    $confirmation = Read-Host "¿Estás SEGURO de que quieres continuar? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Eliminando copias sombra y puntos de restauración..."
        try {
            vssadmin.exe delete shadows /all /quiet
            Write-Log -Level INFO -Message "Se han eliminado correctamente."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error al eliminar las copias sombra: $_"
        }
    } else {
        Write-Log -Level INFO -Message "Operación cancelada por el usuario."
    }
}
