<#
.SYNOPSIS
    Vacia la papelera de reciclaje de todos los usuarios.
.DESCRIPTION
    Usa el cmdlet Clear-RecycleBin con el parÃ¡metro -Force para no pedir confirmaciÃ³n.
#>
function Invoke-ClearRecycleBin {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    Write-Log -Level INFO -Message "Iniciando vaciado de la Papelera de Reciclaje."
    Write-Host -ForegroundColor White "`nVaciando la Papelera de Reciclaje para todos los usuarios..."

    try {
        if ($pscmdlet.ShouldProcess("Papelera de Reciclaje", "Vaciar")) {
            Clear-RecycleBin -Force -ErrorAction Stop
            $message = "La Papelera de Reciclaje ha sido vaciada."
            Write-Log -Level INFO -Message $message
            Write-Host -ForegroundColor Green "(OK) $message"
        }
    } catch {
        $errorMessage = "OcurriÃ³ un error al intentar vaciar la Papelera de Reciclaje."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_"
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
    }
}

