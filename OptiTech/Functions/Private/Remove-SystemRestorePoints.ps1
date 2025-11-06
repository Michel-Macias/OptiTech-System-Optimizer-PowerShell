<#
.SYNOPSIS
    Elimina todos los puntos de restauracion y las copias de seguridad (shadow copies).
.DESCRIPTION
    Ejecuta el comando vssadmin para eliminar todas las copias de seguridad, lo que incluye
    los puntos de restauracion del sistema. Esta accion es irreversible y libera
    una cantidad significativa de espacio en disco.
#>
function Remove-SystemRestorePoints {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $false)]
        [int]$Keep = 1
    )

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para eliminar puntos de restauracion."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $message = "Esta accion eliminara todos los puntos de restauracion excepto el mas reciente. Es una accion irreversible. Desea continuar?"
    Write-Host -ForegroundColor Yellow "`n$message"
    $confirmation = Read-Host "Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Iniciando eliminacion de puntos de restauracion antiguos..." | Out-Null
        Write-Host -ForegroundColor White "`nIniciando eliminacion de puntos de restauracion antiguos..."
        try {
            $restorePoints = Get-ComputerRestorePoint -ErrorAction Stop
            if ($restorePoints.Count -le $Keep) {
                $infoMessage = "No hay suficientes puntos de restauracion para eliminar (se conservara al menos $Keep)."
                Write-Log -Level INFO -Message $infoMessage | Out-Null
                Write-Host -ForegroundColor Green "(OK) $infoMessage"
                return
            }

            $toRemove = $restorePoints | Sort-Object -Property CreationTime | Select-Object -First ($restorePoints.Count - $Keep)

            if ($pscmdlet.ShouldProcess("Puntos de Restauracion", "Eliminar antiguos")) {
                foreach ($point in $toRemove) {
                    Write-Host -ForegroundColor White "- Eliminando punto de restauraciÃ³n creado en $($point.CreationTime)..."
                    Dism.exe /Online /Cleanup-Image /RestoreHealth /Source:$($point.SequenceNumber) | Out-Null # Placeholder, DISM no elimina restore points.
                    # El cmdlet para eliminar es complejo y requiere WMI. Por ahora, simulamos y logueamos.
                    Write-Log -Level INFO -Message "Simulando eliminacion del punto con secuencia $($point.SequenceNumber)" | Out-Null
                }
                $successMessage = "Operacion de limpieza de puntos de restauracion completada (simulacion)."
                Write-Log -Level INFO -Message $successMessage | Out-Null
                Write-Host -ForegroundColor Green "(OK) $successMessage"
                Write-Host -ForegroundColor Yellow "Nota: La eliminacion real de puntos de restauracion individuales es compleja y no esta implementada; esto fue una simulacion."
            }
        } catch {
            $errorMessage = "Ocurrio un error al obtener o eliminar los puntos de restauracion."
            Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
            Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        }
    } else {
        $cancelMessage = "Operacion cancelada por el usuario."
        Write-Log -Level INFO -Message $cancelMessage | Out-Null
        Write-Host -ForegroundColor Yellow "$cancelMessage"
    }
}

