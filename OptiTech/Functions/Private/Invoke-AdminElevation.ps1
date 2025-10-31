<#
.SYNOPSIS
    Solicita la elevación de privilegios si el script no se está ejecutando como administrador.
.DESCRIPTION
    Comprueba si el usuario es administrador usando Test-IsAdmin. Si no lo es,
    reinicia el script actual en una nueva ventana de PowerShell con privilegios elevados
    y cierra el script actual.
#>
function Invoke-AdminElevation {
    if (-not (Test-IsAdmin)) {
        try {
            # Parámetros para iniciar un nuevo proceso de PowerShell con el script actual.
            $params = @{
                FilePath = $psCommandPath # Ruta del script actual.
                Verb = "RunAs" # Indica que se debe ejecutar como administrador.
                ErrorAction = "Stop"
            }
            Start-Process @params
        }
        catch {
            Write-Warning "Error al intentar elevar privilegios: $_"
        }
        # Cierra el script actual para evitar que continúe sin privilegios.
        exit
    }
}
