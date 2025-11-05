<#
.SYNOPSIS
    Desactiva la hibernación del sistema para liberar espacio en disco.
.DESCRIPTION
    Ejecuta el comando powercfg para desactivar la hibernación. Esto elimina el archivo
    hiberfil.sys, que suele ocupar varios gigabytes. Como efecto secundario, también
    se deshabilita la característica de 'Inicio rápido' de Windows.
#>
function Disable-Hibernation {
    Write-Log -Level WARNING -Message "El usuario está considerando desactivar la hibernación." | Out-Null
    Write-Host -ForegroundColor Yellow "`nADVERTENCIA: Esta acción desactivará la hibernación y la característica de 'Inicio rápido' de Windows."
    Write-Host -ForegroundColor Yellow "Esto liberará varios gigabytes de espacio en disco eliminando el archivo 'hiberfil.sys'."
    
    $confirmation = Read-Host "¿Estás seguro de que quieres continuar? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "El usuario confirmó la desactivación de la hibernación." | Out-Null
        Write-Host -ForegroundColor White "`nDesactivando la hibernación..."
        try {
            powercfg.exe /hibernate off
            if ($LASTEXITCODE -ne 0) {
                throw "powercfg.exe falló con código de salida $LASTEXITCODE."
            }
            $message = "Hibernación desactivada. El archivo hiberfil.sys ha sido eliminado."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
        }
        catch {
            $errorMessage = "Ocurrió un error al desactivar la hibernación: $_"
            Write-Log -Level ERROR -Message $errorMessage | Out-Null
            Write-Host -ForegroundColor Red "❌ $errorMessage"
            Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
        }
    } else {
        $message = "Operación cancelada por el usuario."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Yellow "$message"
    }
}
