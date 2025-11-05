<#
.SYNOPSIS
    Crea una copia de seguridad de las ramas principales del Registro de Windows.
.DESCRIPTION
    Crea un directorio 'RegistryBackup' en la ruta del script si no existe.
    Luego, exporta las ramas HKEY_LOCAL_MACHINE y HKEY_CURRENT_USER a archivos .reg
    separados, usando la fecha y hora actual en el nombre del archivo.
#>
function New-RegistryBackup {
    Write-Log -Level INFO -Message "Iniciando copia de seguridad del Registro..."
    $backupDir = "$PSScriptRoot\RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory | Out-Null
        Write-Log -Level INFO -Message "Directorio de copias de seguridad creado en $backupDir"
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $hklmPath = "$backupDir\HKLM_backup_$timestamp.reg"
    $hkcuPath = "$backupDir\HKCU_backup_$timestamp.reg"

    try {
        Write-Log -Level INFO -Message "Exportando HKEY_LOCAL_MACHINE a $hklmPath..."
        reg.exe export HKLM "$hklmPath" /y
        Write-Log -Level INFO -Message "Exportando HKEY_CURRENT_USER a $hkcuPath..."
        reg.exe export HKCU "$hkcuPath" /y
        Write-Log -Level INFO -Message "Copia de seguridad del Registro completada con éxito."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error durante la copia de seguridad del Registro: $_"
    }
}
