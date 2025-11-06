<#
.SYNOPSIS
    Crea una copia de seguridad de las ramas principales del Registro de Windows.
.DESCRIPTION
    Crea un directorio 'RegistryBackup' en la ruta del script si no existe.
    Luego, exporta las ramas HKEY_LOCAL_MACHINE y HKEY_CURRENT_USER a archivos .reg
    separados, usando la fecha y hora actual en el nombre del archivo.
#>
function New-RegistryBackup {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para crear una copia de seguridad del Registro."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $backupDir = Join-Path -Path $script:g_OptiTechRoot -ChildPath "RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory | Out-Null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $hives = @(
        @{ Path = "HKLM:"; Name = "SYSTEM"; File = "$backupDir\SYSTEM_$timestamp.hiv" },
        @{ Path = "HKLM:"; Name = "SOFTWARE"; File = "$backupDir\SOFTWARE_$timestamp.hiv" },
        @{ Path = "HKCU:"; Name = ""; File = "$backupDir\USER_$timestamp.hiv" } # HKCU es un alias para HKEY_USERS\<SID>
    )

    Write-Log -Level INFO -Message "Iniciando copia de seguridad del Registro..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando copia de seguridad del Registro..."

    try {
        if ($pscmdlet.ShouldProcess("Registro de Windows", "Crear copia de seguridad")) {
            foreach ($hive in $hives) {
                $keyPath = if ($hive.Name) { Join-Path -Path $hive.Path -ChildPath $hive.Name } else { $hive.Path }
                Write-Host -ForegroundColor White "- Realizando copia de seguridad de $($keyPath)..."
                Write-Log -Level INFO -Message "Copiando $keyPath a $($hive.File)" | Out-Null
                reg.exe save $keyPath "$($hive.File)" /y | Out-Null
            }
            $successMessage = "Copia de seguridad del Registro completada con Ã©xito en: $backupDir"
            Write-Log -Level INFO -Message $successMessage | Out-Null
            Write-Host -ForegroundColor Green "(OK) $successMessage"
        }
    } catch {
        $errorMessage = "OcurriÃ³ un error al crear la copia de seguridad del Registro."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "AsegÃºrate de estar ejecutando el script como Administrador."
    }
}

