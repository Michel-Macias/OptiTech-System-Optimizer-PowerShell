<#
.SYNOPSIS
    Elimina los archivos de las carpetas temporales del sistema.
.DESCRIPTION
    Limpia el contenido de %SystemRoot%\Temp y %TEMP%.
    Usa -ErrorAction SilentlyContinue para evitar errores si los archivos están en uso.
#>
function Clear-SystemTempFiles {
    Write-Log -Level INFO -Message "Limpiando archivos temporales del sistema..."
    $tempPaths = @("$env:SystemRoot\Temp", "$env:TEMP")
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log -Level INFO -Message "Archivos en $path eliminados."
        } else {
            Write-Log -Level WARNING -Message "El directorio $path no existe."
        }
    }
}
