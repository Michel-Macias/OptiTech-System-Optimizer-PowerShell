<#
.SYNOPSIS
    Vacia la papelera de reciclaje de todos los usuarios.
.DESCRIPTION
    Usa el cmdlet Clear-RecycleBin con el parámetro -Force para no pedir confirmación.
#>
function Invoke-ClearRecycleBin {
    Write-Log -Level INFO -Message "Vaciando la papelera de reciclaje..."
    Microsoft.PowerShell.Management\Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log -Level INFO -Message "Papelera de reciclaje vaciada."
}
