<#
.SYNOPSIS
    Desactiva la hibernación del sistema para liberar espacio en disco.
.DESCRIPTION
    Ejecuta el comando powercfg para desactivar la hibernación. Esto elimina el archivo
    hiberfil.sys, que suele ocupar varios gigabytes. Como efecto secundario, también
    se deshabilita la característica de 'Inicio rápido' de Windows.
#>
function Disable-Hibernation {
    Write-Log -Level WARNING -Message "Esta acción desactivará la hibernación y el 'Inicio rápido' de Windows."
    $confirmation = Read-Host "¿Estás seguro de que quieres continuar? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Desactivando la hibernación..."
        try {
            powercfg.exe /hibernate off
            Write-Log -Level INFO -Message "Hibernación desactivada. El archivo hiberfil.sys ha sido eliminado."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error al desactivar la hibernación: $_"
        }
    } else {
        Write-Log -Level INFO -Message "Operación cancelada por el usuario."
    }
}
