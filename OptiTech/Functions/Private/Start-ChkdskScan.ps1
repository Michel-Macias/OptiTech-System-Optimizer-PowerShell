<#
.SYNOPSIS
    Ejecuta una comprobacion del disco del sistema (chkdsk).
.DESCRIPTION
    Invoca a chkdsk.exe en la unidad C: con los parametros /f /r para corregir errores y recuperar datos.
    Si la unidad esta en uso, programara el analisis para el proximo reinicio del sistema.
#>
function Start-ChkdskScan {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para programar un escaneo Chkdsk."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $message = "Esta accion programara un escaneo del disco del sistema (Chkdsk) en el proximo reinicio. El escaneo puede tardar un tiempo considerable. Desea continuar?"
    Write-Host -ForegroundColor Yellow "`n$message"
    $confirmation = Read-Host "Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Programando escaneo Chkdsk en el proximo reinicio..." | Out-Null
        Write-Host -ForegroundColor White "`nProgramando escaneo Chkdsk en el proximo reinicio..."
        try {
            if ($pscmdlet.ShouldProcess("Disco del Sistema", "Programar Chkdsk")) {
                fsutil dirty set $env:SystemDrive
                $successMessage = "Chkdsk ha sido programado para ejecutarse en el proximo reinicio del sistema."
                Write-Log -Level INFO -Message $successMessage | Out-Null
                Write-Host -ForegroundColor Green "(OK) $successMessage"
            }
        } catch {
            $errorMessage = "Ocurrio un error al programar el escaneo Chkdsk."
            Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
            Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        }
    } else {
        $cancelMessage = "Operacion cancelada por el usuario."
        Write-Log -Level INFO -Message $cancelMessage | Out-Null
        Write-Host -ForegroundColor Yellow "$cancelMessage"
    }
}

