<#
.SYNOPSIS
    Ejecuta una comprobación del disco del sistema (chkdsk).
.DESCRIPTION
    Invoca a chkdsk.exe en la unidad C: con los parámetros /f /r para corregir errores y recuperar datos.
    Si la unidad está en uso, programará el análisis para el próximo reinicio del sistema.
#>
function Start-ChkdskScan {
    Write-Log -Level INFO -Message "Iniciando comprobación de disco (chkdsk C: /f /r)..."
    Write-Log -Level WARNING -Message "Este proceso programará un análisis de la unidad C: en el próximo reinicio."
    
    $confirmation = Read-Host "¿Quieres programar un chkdsk en la unidad C: para el próximo reinicio? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Programando chkdsk..."
        try {
            # Forzamos la respuesta 'S' (Sí) a la pregunta de chkdsk
            echo 'S' | chkdsk C: /f /r
            Write-Log -Level INFO -Message "Se ha programado un análisis de disco para el próximo reinicio."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error al programar chkdsk: $_"
        }
    } else {
        Write-Log -Level INFO -Message "Operación cancelada por el usuario."
    }
}
