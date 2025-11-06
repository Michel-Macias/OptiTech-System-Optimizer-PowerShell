<#
.SYNOPSIS
    Elimina los archivos de las carpetas temporales del sistema.
.DESCRIPTION
    Limpia el contenido de %SystemRoot%\Temp y %TEMP%.
    Usa -ErrorAction SilentlyContinue para evitar errores si los archivos estÃ¡n en uso.
#>
function Clear-SystemTempFiles {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para limpiar los archivos temporales del sistema."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $tempPath = "$env:SystemRoot\Temp"
    Write-Log -Level INFO -Message "Iniciando limpieza de archivos temporales del sistema en $tempPath..." | Out-Null
    Write-Host -ForegroundColor White "`nLimpiando archivos temporales del sistema en $tempPath..."

    if (-not (Test-Path -Path $tempPath)) {
        $message = "El directorio de archivos temporales del sistema no existe: $tempPath"
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "(OK) $message"
        return
    }

    $items = Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    if ($items.Count -eq 0) {
        $message = "No se encontraron archivos temporales del sistema para eliminar."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "(OK) $message"
        return
    }

    if ($pscmdlet.ShouldProcess($tempPath, "Limpiar archivos temporales")) {
        $items | ForEach-Object {
            try {
                Remove-Item -Path $_.FullName -Recurse -Force -ErrorAction Stop
            } catch {
                $errorMessage = "No se pudo eliminar $($_.FullName). Puede que estÃ© en uso."
                Write-Log -Level WARNING -Message "$errorMessage Detalle: $_" | Out-Null
                Write-Host -ForegroundColor Yellow "- $errorMessage"
            }
        }
    }

    $message = "Limpieza de archivos temporales del sistema completada."
    Write-Log -Level INFO -Message $message | Out-Null
    Write-Host -ForegroundColor Green "(OK) $message"
}

