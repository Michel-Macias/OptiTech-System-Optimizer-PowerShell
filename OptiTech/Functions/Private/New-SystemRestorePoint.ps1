<#
.SYNOPSIS
    Crea un punto de restauración del sistema.
.DESCRIPTION
    Utiliza el cmdlet Checkpoint-Computer para crear un punto de restauración
    con una descripción que incluye la fecha y hora actuales.
#>
function New-SystemRestorePoint {
    Write-Log -Level INFO -Message "Iniciando creación de punto de restauración del sistema..." | Out-Null
    Write-Host -ForegroundColor White "`nCreando punto de restauración del sistema..."
    
    $description = "OptiTech Restore Point - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    
    try {
        Checkpoint-Computer -Description $description -ErrorAction Stop
        $message = "Punto de restauración '$description' creado con éxito."
        Write-Log -Level INFO -Message "Punto de restauración '$description' creado." | Out-Null
        Write-Host -ForegroundColor Green "✔ $message"
    }
    catch {
        $errorMessage = "Ocurrió un error al crear el punto de restauración: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}
