<#
.SYNOPSIS
    Elimina los archivos de las carpetas temporales del sistema.
.DESCRIPTION
    Limpia el contenido de %SystemRoot%\Temp y %TEMP%.
    Usa -ErrorAction SilentlyContinue para evitar errores si los archivos están en uso.
#>
function Clear-SystemTempFiles {
    Write-Log -Level INFO -Message "Iniciando limpieza de archivos temporales del sistema." | Out-Null
    $tempPath = "$env:SystemRoot\Temp"
    
    if (-not (Test-Path -Path $tempPath)) {
        Write-Log -Level WARNING -Message "El directorio de sistema temporal '$tempPath' no existe." | Out-Null
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
            Write-Progress -Activity "Limpiando archivos temporales del sistema" -Status "Eliminando $($item.Name)" -PercentComplete $percentComplete
            $item | Remove-Item -Recurse -Force -ErrorAction Stop # Forzar error para que lo capture el catch
        } catch {
            # Ignorar el error si el archivo no se encuentra (ya fue eliminado) o está en uso.
            Write-Log -Level INFO -Message "No se pudo eliminar $($item.FullName) (probablemente en uso o ya no existe)." | Out-Null
        }
    }
    Write-Progress -Activity "Limpiando archivos temporales del sistema" -Completed

    $sizeFreedGB = [math]::Round($totalSize / 1GB, 2)
    $message = "Limpieza de archivos temporales del sistema completada. Se liberaron aproximadamente $($sizeFreedGB) GB."
    Write-Log -Level INFO -Message $message | Out-Null
    Write-Host -ForegroundColor Green "✔ $message"
}
