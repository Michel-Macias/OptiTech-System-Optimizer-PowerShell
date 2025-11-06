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
        @{ Path = "HKLM\SYSTEM"; File = "$backupDir\SYSTEM_$timestamp.reg" },
        @{ Path = "HKLM\SOFTWARE"; File = "$backupDir\SOFTWARE_$timestamp.reg" }
    )

    Write-Log -Level INFO -Message "Iniciando copia de seguridad del Registro..." | Out-Null
    Write-Host -ForegroundColor White "`nIniciando copia de seguridad del Registro..."

    try {
        if ($pscmdlet.ShouldProcess("Registro de Windows", "Crear copia de seguridad")) {
            foreach ($hive in $hives) {
                $keyPath = $hive.Path
                Write-Host -ForegroundColor White "- Realizando copia de seguridad de $($keyPath)..."
                Write-Log -Level INFO -Message "Copiando $keyPath a $($hive.File)" | Out-Null
                reg.exe export $keyPath "$($hive.File)" /y 2>$null | Out-Null
            }
            $successMessage = "Copia de seguridad de las ramas principales del Registro completada con éxito en: $backupDir"
            Write-Log -Level INFO -Message $successMessage | Out-Null
            Write-Host -ForegroundColor Green "(OK) $successMessage"
        }
    } catch {
        $errorMessage = "Ocurrió un error al crear la copia de seguridad del Registro."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}

