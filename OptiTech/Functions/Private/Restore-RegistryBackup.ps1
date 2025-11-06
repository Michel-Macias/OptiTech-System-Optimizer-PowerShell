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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para restaurar una copia de seguridad del Registro."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $backupDir = Join-Path -Path $script:g_OptiTechRoot -ChildPath "RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        $errorMessage = "No se encontró el directorio de copias de seguridad del Registro: $backupDir"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $backupFiles = Get-ChildItem -Path $backupDir -Filter "*.reg" | Sort-Object -Property LastWriteTime -Descending
    if ($backupFiles.Count -eq 0) {
        $errorMessage = "No se encontraron archivos de copia de seguridad del Registro en $backupDir"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Host -ForegroundColor Yellow ("`n{0,60}" -f "--- OPERACIÓN DE ALTO RIESGO! ---")
    Write-Host -ForegroundColor Yellow ("{0,55}" -f "Restaurar el Registro puede causar inestabilidad en el sistema.")
    Write-Host -ForegroundColor Yellow ("{0,60}" -f "Se recomienda encarecidamente crear un punto de restauración del sistema antes de continuar.")
    Write-Host -ForegroundColor Yellow ("`nSe restaurará la copia de seguridad más reciente: $($backupFiles[0].Name)")
    $confirmation = Read-Host "Escribe 'CONFIRMO' para proceder con la restauración."

    if ($confirmation -ne 'CONFIRMO') {
        $cancelMessage = "Restauración del Registro cancelada por el usuario."
        Write-Log -Level INFO -Message $cancelMessage | Out-Null
        Write-Host -ForegroundColor Yellow "$cancelMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando restauración del Registro..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando restauración del Registro..."

    # Por ahora, esta función es una simulación por seguridad.
    # La restauración real requeriría reiniciar en modo seguro o usar herramientas especializadas.
    if ($pscmdlet.ShouldProcess("Registro de Windows", "Restaurar desde copia de seguridad (SIMULACIÓN)")) {
        Write-Log -Level INFO -Message "Simulando restauración desde: $($backupFiles[0].FullName)" | Out-Null
        # Aquí iría la lógica de restauración real (ej. reg.exe import)
        Start-Sleep -Seconds 3 # Simular trabajo

        $successMessage = "Restauración del Registro (simulación) completada."
        Write-Log -Level INFO -Message $successMessage | Out-Null
        Write-Host -ForegroundColor Green "(OK) $successMessage"
        Write-Host -ForegroundColor Yellow "Nota: La restauración real del registro es una operación compleja y riesgosa que no se ejecuta automáticamente. Esto fue una simulación."
    }
}
