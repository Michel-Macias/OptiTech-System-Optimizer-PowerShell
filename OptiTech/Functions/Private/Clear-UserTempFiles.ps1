<#
.SYNOPSIS
    Elimina los archivos de la carpeta temporal del perfil de usuario.
.DESCRIPTION
    Limpia el contenido de %USERPROFILE%\AppData\Local\Temp.
#>
function Clear-UserTempFiles {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    $tempPath = $env:TEMP
    Write-Log -Level INFO -Message "Iniciando limpieza de archivos temporales del usuario en $tempPath..." | Out-Null
    Write-Host -ForegroundColor White "`nLimpiando archivos temporales del usuario en $tempPath..."

    if (-not (Test-Path -Path $tempPath)) {
        $message = "El directorio de archivos temporales del usuario no existe: $tempPath"
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "(OK) $message"
        return
    }

    $items = Get-ChildItem -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    if ($items.Count -eq 0) {
        $message = "No se encontraron archivos temporales del usuario para eliminar."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "(OK) $message"
        return
    }

    if ($pscmdlet.ShouldProcess($tempPath, "Limpiar archivos temporales")) {
        $items | ForEach-Object {
            $currentItemFullName = $_.FullName
            try {
                Remove-Item -Path $currentItemFullName -Recurse -Force -ErrorAction Stop
            } catch {
                $errorMessage = "No se pudo eliminar $currentItemFullName. Puede que esté en uso."
                Write-Log -Level WARNING -Message "$errorMessage Detalle: $_" | Out-Null
                Write-Host -ForegroundColor Yellow "- $errorMessage"
            }
        }
    }

    $message = "Limpieza de archivos temporales del usuario completada."
    Write-Log -Level INFO -Message $message | Out-Null
    Write-Host -ForegroundColor Green "(OK) $message"
}

