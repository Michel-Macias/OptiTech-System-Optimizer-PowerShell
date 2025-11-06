<#
.SYNOPSIS
    Desactiva la hibernacion del sistema para liberar espacio en disco.
.DESCRIPTION
    Ejecuta el comando powercfg para desactivar la hibernacion. Esto elimina el archivo
    hiberfil.sys, que suele ocupar varios gigabytes. Como efecto secundario, tambien
    se deshabilita la caracteristica de 'Inicio rapido' de Windows.
#>
function Disable-Hibernation {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para deshabilitar la hibernacion."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $message = "Deshabilitar la hibernacion liberara espacio en disco (el tamano del archivo hiberfil.sys), pero no podras usar el modo de hibernacion. Desea continuar?"
    Write-Host -ForegroundColor Yellow "`n$message"
    $confirmation = Read-Host "Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Deshabilitando la hibernacion..." | Out-Null
        Write-Host -ForegroundColor White "`nDeshabilitando la hibernacion..."
        try {
            if ($pscmdlet.ShouldProcess("Sistema", "Deshabilitar Hibernacion")) {
                powercfg /hibernate off
                $successMessage = "Hibernacion deshabilitada correctamente."
                Write-Log -Level INFO -Message $successMessage | Out-Null
                Write-Host -ForegroundColor Green "(OK) $successMessage"
            }
        } catch {
            $errorMessage = "Ocurrio un error al intentar deshabilitar la hibernacion."
            Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
            Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        }
    } else {
        $cancelMessage = "Operacion cancelada por el usuario."
        Write-Log -Level INFO -Message $cancelMessage | Out-Null
        Write-Host -ForegroundColor Yellow "$cancelMessage"
    }
}

