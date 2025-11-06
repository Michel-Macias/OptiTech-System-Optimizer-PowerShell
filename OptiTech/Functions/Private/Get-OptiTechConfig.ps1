<#
.SYNOPSIS
    Carga la configuracion desde el archivo config.json.
.DESCRIPTION
    Lee el archivo config.json ubicado en la raiz del modulo, lo convierte
    desde formato JSON a un objeto de PowerShell y lo devuelve.
.OUTPUTS
    [PSCustomObject] - El objeto de configuracion.
#>
function Get-OptiTechConfig {
    [CmdletBinding()]
    param(
        [string]$Section
    )

    # Se utiliza la variable de script definida en el .psm1 para encontrar la raiz del modulo.
    $configPath = Join-Path -Path $script:g_OptiTechRoot -ChildPath 'config.json'

    if (-not (Test-Path -Path $configPath)) {
        Write-Error "El archivo de configuracion '$configPath' no se encontro."
        return $null
    }

    try {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        if ($PSBoundParameters.ContainsKey('Section') -and $Section) {
            return $config.$Section
        }
        return $config
    }
    catch {
        Write-Error "Error al leer o procesar el archivo de configuracion '$configPath': $_"
        return $null
    }
}

