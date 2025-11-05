<#
.SYNOPSIS
    Crea una copia de seguridad de las ramas principales del Registro de Windows.
.DESCRIPTION
    Crea un directorio 'RegistryBackup' en la ruta del script si no existe.
    Luego, exporta las ramas HKEY_LOCAL_MACHINE y HKEY_CURRENT_USER a archivos .reg
    separados, usando la fecha y hora actual en el nombre del archivo.
#>
function New-RegistryBackup {
    Write-Log -Level INFO -Message "Iniciando copia de seguridad del Registro..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando copia de seguridad del Registro..."

    # Usar la ruta raíz del módulo para guardar las copias de seguridad de forma consistente.
    $backupDir = "$script:g_OptiTechRoot\RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory | Out-Null
        Write-Log -Level INFO -Message "Directorio de copias de seguridad creado en $backupDir" | Out-Null
        Write-Host -ForegroundColor White "- Directorio de copias de seguridad creado en: $backupDir"
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $hklmPath = "$backupDir\HKLM_backup_$timestamp.reg"
    $hkcuPath = "$backupDir\HKCU_backup_$timestamp.reg"

    try {
        Write-Host -ForegroundColor White "- Exportando HKEY_LOCAL_MACHINE..."
        Write-Log -Level INFO -Message "Exportando HKEY_LOCAL_MACHINE a $hklmPath..." | Out-Null
        reg.exe export HKLM "$hklmPath" /y
        if ($LASTEXITCODE -ne 0) { throw "reg.exe export HKLM falló." }

        Write-Host -ForegroundColor White "- Exportando HKEY_CURRENT_USER..."
        Write-Log -Level INFO -Message "Exportando HKEY_CURRENT_USER a $hkcuPath..." | Out-Null
        reg.exe export HKCU "$hkcuPath" /y
        if ($LASTEXITCODE -ne 0) { throw "reg.exe export HKCU falló." }

        $message = "Copia de seguridad del Registro completada con éxito."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "`n✔ $message"
        Write-Host -ForegroundColor Green "  Los archivos se encuentran en: $backupDir"
    }
    catch {
        $errorMessage = "Ocurrió un error durante la copia de seguridad del Registro: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}
