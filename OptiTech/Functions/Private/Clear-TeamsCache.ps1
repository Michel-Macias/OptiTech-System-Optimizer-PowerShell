<#
.SYNOPSIS
    Limpia la caché de la aplicación de escritorio de Microsoft Teams.

.DESCRIPTION
    Localiza y elimina el contenido de las carpetas de caché de Microsoft Teams para el usuario actual.
    Esto puede solucionar problemas de la aplicación y liberar espacio en disco. La función se enfoca
    en la nueva versión de Teams ("Teams") y la clásica ("Teams Classic").

.NOTES
    Se recomienda cerrar Microsoft Teams antes de ejecutar esta función para asegurar que todos
    los archivos puedan ser eliminados.
#>
function Clear-TeamsCache {
    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de Microsoft Teams..."

    # Rutas de caché para la nueva versión de Teams y la clásica.
    # La nueva versión usa subcarpetas dentro de %LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe\
    $newTeamsPath = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe"
    # La versión clásica usa %APPDATA%\Microsoft\Teams
    $classicTeamsPath = "$env:APPDATA\Microsoft\Teams"

    $cachePaths = @()
    if (Test-Path -Path $newTeamsPath) {
        $cachePaths += Get-ChildItem -Path $newTeamsPath -Directory -Recurse | Where-Object { $_.Name -in @('Cache', 'Code Cache', 'GPUCache') } | Select-Object -ExpandProperty FullName
    }
    if (Test-Path -Path $classicTeamsPath) {
        $cachePaths += Get-ChildItem -Path $classicTeamsPath -Directory -Recurse | Where-Object { $_.Name -in @('Cache', 'Code Cache', 'GPUCache', 'Application Cache') } | Select-Object -ExpandProperty FullName
    }

    if ($cachePaths.Count -eq 0) {
        Write-Log -Level INFO -Message "No se encontraron carpetas de caché de Microsoft Teams para el usuario actual."
        return
    }

    foreach ($path in $cachePaths) {
        Write-Log -Level INFO -Message "Limpiando carpeta: $path"
        try {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction Stop
            Write-Log -Level INFO -Message "Contenido de $path eliminado correctamente."
        }
        catch {
            Write-Log -Level WARNING -Message "No se pudo eliminar todo el contenido de $path. Es posible que Teams siga en ejecución. Detalles: $_"
        }
    }

    Write-Log -Level INFO -Message "Limpieza de la caché de Microsoft Teams finalizada."
}
