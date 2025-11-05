<#
.SYNOPSIS
    Ejecuta una comprobación del disco del sistema (chkdsk).
.DESCRIPTION
    Invoca a chkdsk.exe en la unidad C: con los parámetros /f /r para corregir errores y recuperar datos.
    Si la unidad está en uso, programará el análisis para el próximo reinicio del sistema.
#>
function Start-ChkdskScan {
    Write-Log -Level INFO -Message "El usuario ha iniciado la función de chkdsk." | Out-Null
    Write-Host -ForegroundColor Yellow "`nADVERTENCIA: Este proceso programará un análisis de la unidad C: en el próximo reinicio del sistema."
    Write-Host -ForegroundColor Yellow "El análisis se ejecutará antes de que Windows se inicie y puede tardar mucho tiempo."
    
    $confirmation = Read-Host "¿Quieres programar un chkdsk en la unidad C: para el próximo reinicio? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "El usuario confirmó la programación de chkdsk." | Out-Null
        Write-Host -ForegroundColor White "`nProgramando chkdsk..."
        try {
            # Forzamos la respuesta 'S' (Sí) a la pregunta de chkdsk
            $output = echo 'S' | chkdsk C: /f /r 2>&1
            if ($LASTEXITCODE -ne 0) {
                # chkdsk puede devolver códigos de salida distintos de 0 incluso si programa correctamente.
                # Buscamos el texto de confirmación en la salida.
                if ($output -notmatch 'se programó') {
                    throw $output
                }
            }
            $message = "Se ha programado un análisis de disco para el próximo reinicio."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
        }
        catch {
            $errorMessage = "Ocurrió un error al programar chkdsk: $_"
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
