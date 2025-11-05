<#
.SYNOPSIS
    Elimina todos los puntos de restauración y las copias sombra (shadow copies).
.DESCRIPTION
    Ejecuta el comando vssadmin para eliminar todas las copias sombra, lo que incluye
    los puntos de restauración del sistema. Esta acción es irreversible y libera
    una cantidad significativa de espacio en disco.
#>
function Remove-SystemRestorePoints {
    Write-Log -Level WARNING -Message "El usuario está considerando eliminar todos los puntos de restauración." | Out-Null
    Write-Host -ForegroundColor Yellow "ADVERTENCIA: Esta acción eliminará TODOS los puntos de restauración del sistema y las copias sombra."
    Write-Host -ForegroundColor Yellow "No podrás revertir el sistema a un estado anterior. Esta acción es IRREVERSIBLE."
    
    $confirmation = Read-Host "`n¿Estás SEGURO de que quieres continuar? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "El usuario confirmó la eliminación. Procediendo..." | Out-Null
        Write-Host -ForegroundColor White "`nEliminando copias sombra y puntos de restauración..."
        try {
            # El comando vssadmin requiere elevación. La salida se redirige para que no 'ensucie' la consola.
            $output = vssadmin.exe delete shadows /all /quiet 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "vssadmin.exe falló con código de salida $LASTEXITCODE. Salida: $output"
            }
            $message = "Se han eliminado correctamente los puntos de restauración."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
        }
        catch {
            $errorMessage = "Ocurrió un error al eliminar las copias sombra: $_"
            Write-Log -Level ERROR -Message $errorMessage | Out-Null
            Write-Host -ForegroundColor Red "❌ $errorMessage"
            Write-Host -ForegroundColor Red "Este comando generalmente requiere ejecución como Administrador."
        }
    } else {
        $message = "Operación cancelada por el usuario."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Yellow "$message"
    }
}
