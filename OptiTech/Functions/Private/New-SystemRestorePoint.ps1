<#
.SYNOPSIS
    Crea un punto de restauracion del sistema.
.DESCRIPTION
    Utiliza el cmdlet Checkpoint-Computer para crear un punto de restauracion
    con una descripcion que incluye la fecha y hora actuales.
#>
function New-SystemRestorePoint {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para crear un punto de restauracion."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando creacion de punto de restauracion del sistema..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando creacion de punto de restauracion del sistema..."

    try {
        if ($pscmdlet.ShouldProcess("Sistema", "Crear Punto de Restauracion")) {
            $description = "OptiTech System Optimization - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            Checkpoint-Computer -Description $description -ErrorAction Stop
            $message = "Punto de restauracion del sistema creado con exito."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"
        }
    } catch {
        $errorMessage = "Ocurrio un error al crear el punto de restauracion."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "Asegurate de estar ejecutando el script como Administrador."
    }
}

