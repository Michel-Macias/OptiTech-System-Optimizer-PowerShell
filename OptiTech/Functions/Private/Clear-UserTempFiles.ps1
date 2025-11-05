<#
.SYNOPSIS
    Elimina los archivos de la carpeta temporal del perfil de usuario.
.DESCRIPTION
    Limpia el contenido de %USERPROFILE%\AppData\Local\Temp.
#>
function Clear-UserTempFiles {
    Write-Log -Level INFO -Message "Iniciando limpieza de archivos temporales del usuario." | Out-Null
    $tempPath = "$env:TEMP"

    if (-not (Test-Path -Path $tempPath)) {
        Write-Log -Level WARNING -Message "El directorio de usuario temporal '$tempPath' no existe." | Out-Null
        return
    }

    $itemsToDelete = Get-ChildItem -Path $tempPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) }
    $filesToDelete = $itemsToDelete | Where-Object { -not $_.PSIsContainer }
    $totalSize = 0
    if ($filesToDelete) {
        $totalSize = ($filesToDelete | Measure-Object -Property Length -Sum).Sum
    }

    $itemCount = $itemsToDelete.Count
    for ($i = 0; $i -lt $itemCount; $i++) {
        $item = $itemsToDelete[$i]
        try {
            $percentComplete = ($i / $itemCount) * 100
            Write-Progress -Activity "Limpiando archivos temporales del usuario" -Status "Eliminando $($item.Name)" -PercentComplete $percentComplete
            $item | Remove-Item -Recurse -Force -ErrorAction Stop # Forzar error para que lo capture el catch
        } catch {
            # Ignorar el error si el archivo no se encuentra (ya fue eliminado) o está en uso.
            Write-Log -Level INFO -Message "No se pudo eliminar $($item.FullName) (probablemente en uso o ya no existe)." | Out-Null
        }
    }
    Write-Progress -Activity "Limpiando archivos temporales del usuario" -Completed

    $sizeFreedGB = [math]::Round($totalSize / 1GB, 2)
    $message = "Limpieza de archivos temporales del usuario completada. Se liberaron aproximadamente $($sizeFreedGB) GB."
    Write-Log -Level INFO -Message $message | Out-Null
    Write-Host -ForegroundColor Green "✔ $message"
}
