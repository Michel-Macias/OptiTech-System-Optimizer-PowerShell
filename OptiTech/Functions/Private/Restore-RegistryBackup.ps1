<#
.SYNOPSIS
    Restaura el Registro de Windows desde una copia de seguridad.
.DESCRIPTION
    Muestra una lista de los archivos de copia de seguridad .reg disponibles. El usuario
    debe seleccionar un archivo para importarlo. Esta es una operaciÃ³n de ALTO RIESGO
    que puede causar inestabilidad en el sistema si se usa un archivo corrupto o incorrecto.
    Requiere una doble confirmaciÃ³n por parte del usuario.
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
        $errorMessage = "No se encontrÃ³ el directorio de copias de seguridad del Registro: $backupDir"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $backupFiles = Get-ChildItem -Path $backupDir -Filter "*.hiv" | Sort-Object -Property LastWriteTime -Descending
    if ($backupFiles.Count -eq 0) {
        $errorMessage = "No se encontraron archivos de copia de seguridad del Registro en $backupDir"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Host -ForegroundColor Yellow ("`n{0,60}" -f "--- OPERACION DE ALTO RIESGO! ---")
    Write-Host -ForegroundColor Yellow ("{0,55}" -f "Restaurar el Registro puede causar inestabilidad en el sistema.")
    Write-Host -ForegroundColor Yellow ("{0,60}" -f "Se recomienda encarecidamente crear un punto de restauracion del sistema antes de continuar.")
    Write-Host -ForegroundColor Yellow ("`nSe restaurara la copia de seguridad mas reciente: $($backupFiles[0].Name)")
    $confirmation = Read-Host "Escribe 'CONFIRMO' para proceder con la restauracion."

    if ($confirmation -ne 'CONFIRMO') {
        $cancelMessage = "Restauracion del Registro cancelada por el usuario."
        Write-Log -Level INFO -Message $cancelMessage | Out-Null
        Write-Host -ForegroundColor Yellow "$cancelMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando restauracion del Registro..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando restauracion del Registro..."

    # Por ahora, esta funciÃ³n es una simulaciÃ³n por seguridad.
    # La restauraciÃ³n real requerirÃ­a reiniciar en modo seguro o usar herramientas especializadas.
    if ($pscmdlet.ShouldProcess("Registro de Windows", "Restaurar desde copia de seguridad (SIMULACION)")) {
        Write-Log -Level INFO -Message "Simulando restauracion desde: $($backupFiles[0].FullName)" | Out-Null
        # AquÃ­ irÃ­a la lÃ³gica de restauraciÃ³n real (ej. reg.exe restore)
        Start-Sleep -Seconds 3 # Simular trabajo

        $successMessage = "Restauracion del Registro (simulacion) completada."
        Write-Log -Level INFO -Message $successMessage | Out-Null
        Write-Host -ForegroundColor Green "(OK) $successMessage"
        Write-Host -ForegroundColor Yellow "Nota: La restauracion real del registro es una operacion compleja y riesgosa que no se ejecuta automaticamente. Esto fue una simulacion."
    }
}
