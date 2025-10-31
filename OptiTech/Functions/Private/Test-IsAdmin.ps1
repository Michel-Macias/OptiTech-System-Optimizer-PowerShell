<#
.SYNOPSIS
    Verifica si el script se está ejecutando con privilegios de administrador.
.DESCRIPTION
    Intenta acceder a una clave del registro en HKLM que requiere elevación.
    Si tiene éxito, devuelve $true; de lo contrario, captura la excepción y devuelve $false.
.OUTPUTS
    [bool] - $true si es administrador, $false en caso contrario.
#>
function Test-IsAdmin {
    try {
        # Intenta leer una clave de registro que solo los administradores pueden leer.
        Get-Item -Path "HKLM:\SOFTWARE\Microsoft" -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        # Si se produce un error de acceso, no es administrador.
        return $false
    }
}
