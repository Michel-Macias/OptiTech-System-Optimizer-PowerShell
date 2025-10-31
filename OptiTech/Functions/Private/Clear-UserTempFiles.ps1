<#
.SYNOPSIS
    Elimina los archivos de la carpeta temporal del perfil de usuario.
.DESCRIPTION
    Limpia el contenido de %USERPROFILE%\AppData\Local\Temp.
#>
function Clear-UserTempFiles {
    Write-Log -Level INFO -Message "Limpiando archivos temporales del usuario..."
    $userTemp = "$env:USERPROFILE\AppData\Local\Temp"
    if (Test-Path $userTemp) {
        Remove-Item -Path "$userTemp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Level INFO -Message "Archivos en $userTemp eliminados."
    } else {
        Write-Log -Level WARNING -Message "El directorio $userTemp no existe."
    }
}
