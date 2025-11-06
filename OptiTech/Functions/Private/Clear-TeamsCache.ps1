<#
.SYNOPSIS
    Limpia la cache de la aplicacion de escritorio de Microsoft Teams.

.DESCRIPTION
    Localiza y elimina el contenido de las carpetas de cache de Microsoft Teams para el usuario actual.
    Esto puede solucionar problemas de la aplicacion y liberar espacio en disco. La funcion se enfoca
    en la nueva version de Teams ("Teams") y la clasica ("Teams Classic").

.NOTES
    Se recomienda cerrar Microsoft Teams antes de ejecutar esta funcion para asegurar que todos
    los archivos puedan ser eliminados.
#>
function Clear-TeamsCache {
    Write-Log -Level INFO -Message "Iniciando limpieza de la cache de Microsoft Teams..." | Out-Null
    Write-Host -ForegroundColor White "`nBuscando carpetas de cache de Microsoft Teams..."

    # Rutas de cachÃ© para la nueva versiÃ³n de Teams y la clÃ¡sica.
    $newTeamsPath = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe"
    $classicTeamsPath = "$env:APPDATA\Microsoft\Teams"

    $cachePaths = @()
    if (Test-Path -Path $newTeamsPath) {
        $cachePaths += Get-ChildItem -Path $newTeamsPath -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @('Cache', 'Code Cache', 'GPUCache') } | Select-Object -ExpandProperty FullName
    }
    if (Test-Path -Path $classicTeamsPath) {
        $cachePaths += Get-ChildItem -Path $classicTeamsPath -Directory -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -in @('Cache', 'Code Cache', 'GPUCache', 'Application Cache') } | Select-Object -ExpandProperty FullName
    }

    if ($cachePaths.Count -eq 0) {
        $message = "No se encontraron carpetas de cache de Microsoft Teams para el usuario actual."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Green "(OK) $message"
        return
    }

    Write-Host -ForegroundColor Yellow "Se recomienda cerrar Microsoft Teams antes de continuar para asegurar que todos los archivos puedan ser eliminados."
    $confirmation = Read-Host "Quieres limpiar las carpetas de cache encontradas? Escribe 'SI' para confirmar."

    if ($confirmation -ne 'SI') {
        $message = "Operacion cancelada por el usuario."
        Write-Log -Level INFO -Message $message | Out-Null
        Write-Host -ForegroundColor Yellow "$message"
        return
    }

    foreach ($path in $cachePaths) {
        Write-Host -ForegroundColor White "Limpiando carpeta: $path"
        Write-Log -Level INFO -Message "Limpiando carpeta: $path" | Out-Null
        try {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction Stop
        }
        catch {
            $errorMessage = "No se pudo eliminar todo el contenido de $path. Es posible que Teams siga en ejecucion."
            Write-Log -Level WARNING -Message "$errorMessage Detalles: $_" | Out-Null
            Write-Host -ForegroundColor Yellow "- $errorMessage"
        }
    }

    $finalMessage = "Limpieza de la cache de Microsoft Teams finalizada."
    Write-Log -Level INFO -Message $finalMessage | Out-Null
    Write-Host -ForegroundColor Green "`n(OK) $finalMessage"
}

