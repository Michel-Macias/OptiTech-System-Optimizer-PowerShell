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
    Write-Log -Level WARNING -Message "El usuario ha iniciado la función de restauración del Registro." | Out-Null
    Write-Host -ForegroundColor Red -Object ("`n{0,60}" -f "--- ¡OPERACIÓN DE ALTO RIESGO! ---")
    Write-Host -ForegroundColor Yellow "Restaurar el Registro puede causar daños graves e irreversibles en el sistema si algo sale mal."
    Write-Host -ForegroundColor Yellow "Procede solo si sabes exactamente lo que estás haciendo."

    $backupDir = "$script:g_OptiTechRoot\RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        $errorMessage = "El directorio de copias de seguridad '$backupDir' no existe. No hay nada que restaurar."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "`n❌ $errorMessage"
        return
    }

    $backups = Get-ChildItem -Path $backupDir -Filter "*.reg"
    if ($backups.Count -eq 0) {
        $warningMessage = "No se encontraron archivos de copia de seguridad (.reg) en $backupDir."
        Write-Log -Level WARNING -Message $warningMessage | Out-Null
        Write-Host -ForegroundColor Yellow "`n- $warningMessage"
        return
    }

    Write-Host -ForegroundColor Cyan "`nCopias de seguridad disponibles:"
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host -NoNewline -ForegroundColor Yellow ("{0}: " -f ($i + 1)); Write-Host $backups[$i].Name
    }

    $choice = Read-Host "`nSelecciona el NÚMERO del archivo que quieres restaurar (o presiona Enter para cancelar)"
    if ([string]::IsNullOrWhiteSpace($choice) -or $choice -notmatch '^\d+
) {
        $message = "Restauración cancelada."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Yellow "$message"
        return
    }

    $index = [int]$choice - 1
    if ($index -lt 0 -or $index -ge $backups.Count) {
        $errorMessage = "Selección no válida."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
        return
    }

    $fileToRestore = $backups[$index]
    Write-Host -ForegroundColor Yellow "`nHas seleccionado restaurar desde el archivo ' $($fileToRestore.Name)'."
    $confirmation = Read-Host "Para confirmar esta acción PELIGROSA, escribe el nombre completo del archivo de nuevo"

    if ($confirmation -eq $fileToRestore.Name) {
        Write-Log -Level INFO -Message "El usuario ha confirmado la restauración desde '$($fileToRestore.FullName)'." | Out-Null
        Write-Host -ForegroundColor White "`nIniciando la restauración del Registro..."
        try {
            reg.exe import "$($fileToRestore.FullName)"
            if ($LASTEXITCODE -ne 0) { throw "reg.exe import falló." }
            $message = "Restauración del Registro completada. Se recomienda reiniciar el equipo."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
        }
        catch {
            $errorMessage = "Ocurrió un error durante la restauración: $_"
            Write-Log -Level ERROR -Message $errorMessage | Out-Null
            Write-Host -ForegroundColor Red "❌ $errorMessage"
            Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
        }
    } else {
        $message = "La confirmación no coincide. Operación de restauración cancelada."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Yellow "$message"
    }
}
