<#
.SYNOPSIS
    Vacia la papelera de reciclaje de todos los usuarios.
.DESCRIPTION
    Usa el cmdlet Clear-RecycleBin con el parámetro -Force para no pedir confirmación.
#>
function Invoke-ClearRecycleBin {
    Write-Log -Level INFO -Message "Iniciando vaciado de la papelera de reciclaje..." | Out-Null
    Write-Host -ForegroundColor White "`nVaciando la papelera de reciclaje..."
    try {
        Microsoft.PowerShell.Management\Clear-RecycleBin -Force -ErrorAction Stop
        $message = "Papelera de reciclaje vaciada correctamente."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "✔ $message"
    }
    catch {
        $errorMessage = "Ocurrió un error al vaciar la papelera de reciclaje: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
    }
}
