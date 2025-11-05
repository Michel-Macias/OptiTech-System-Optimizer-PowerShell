<#
.SYNOPSIS
    Restaura el Registro de Windows desde una copia de seguridad.
.DESCRIPTION
    Muestra una lista de los archivos de copia de seguridad .reg disponibles. El usuario
    debe seleccionar un archivo para importarlo. Esta es una operación de ALTO RIESGO
    que puede causar inestabilidad en el sistema si se usa un archivo corrupto o incorrecto.
    Requiere una doble confirmación por parte del usuario.
#>
function Restore-RegistryBackup {
    Write-Log -Level WARNING -Message "--- ¡OPERACIÓN DE ALTO RIESGO! ---"
    Write-Log -Level WARNING -Message "Restaurar el Registro puede causar daños graves e irreversibles en el sistema si algo sale mal."
    
    $backupDir = "$PSScriptRoot\RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        Write-Log -Level ERROR -Message "El directorio de copias de seguridad '$backupDir' no existe. No hay nada que restaurar."
        return
    }

    $backups = Get-ChildItem -Path $backupDir -Filter "*.reg"
    if ($backups.Count -eq 0) {
        Write-Log -Level WARNING -Message "No se encontraron archivos de copia de seguridad (.reg) en $backupDir."
        return
    }

    Write-Log -Level INFO -Message "Copias de seguridad disponibles:"
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host ("{0}: {1}" -f ($i + 1), $backups[$i].Name)
    }

    $choice = Read-Host "Selecciona el NÚMERO del archivo que quieres restaurar (o presiona Enter para cancelar)"
    if ([string]::IsNullOrWhiteSpace($choice) -or $choice -notmatch '^\d+$') {
        Write-Log -Level INFO -Message "Restauración cancelada."
        return
    }

    $index = [int]$choice - 1
    if ($index -lt 0 -or $index -ge $backups.Count) {
        Write-Log -Level ERROR -Message "Selección no válida."
        return
    }

    $fileToRestore = $backups[$index]
    Write-Log -Level WARNING -Message "Has seleccionado restaurar desde el archivo '$($fileToRestore.Name)'."
    $confirmation = Read-Host "Para confirmar esta acción PELIGROSA, escribe el nombre completo del archivo de nuevo."

    if ($confirmation -eq $fileToRestore.Name) {
        Write-Log -Level INFO -Message "Iniciando la restauración del Registro desde '$($fileToRestore.FullName)'..."
        try {
            reg.exe import "$($fileToRestore.FullName)"
            Write-Log -Level INFO -Message "Restauración del Registro completada. Se recomienda reiniciar el equipo."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error durante la restauración: $_"
        }
    } else {
        Write-Log -Level INFO -Message "La confirmación no coincide. Operación de restauración cancelada."
    }
}
