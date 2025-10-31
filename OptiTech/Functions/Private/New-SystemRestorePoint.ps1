<#
.SYNOPSIS
    Crea un punto de restauración del sistema.
.DESCRIPTION
    Utiliza el cmdlet Checkpoint-Computer para crear un punto de restauración
    con una descripción que incluye la fecha y hora actuales.
#>
function New-SystemRestorePoint {
    Write-Log -Level INFO -Message "Creando punto de restauración del sistema..."
    $description = "OptiTech Restore Point - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Checkpoint-Computer -Description $description
    Write-Log -Level INFO -Message "Punto de restauración '$description' creado."
}
