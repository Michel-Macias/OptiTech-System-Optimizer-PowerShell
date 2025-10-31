<#
.SYNOPSIS
    Carga la configuración desde el archivo config.json.
.DESCRIPTION
    Lee el archivo config.json ubicado en la raíz del módulo, lo convierte
    desde formato JSON a un objeto de PowerShell y lo devuelve.
.OUTPUTS
    [PSCustomObject] - El objeto de configuración.
#>
function Get-OptiTechConfig {
    # $PSScriptRoot se define en el .psm1 y es accesible para todas las funciones del módulo.
    $configPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'

    if (-not (Test-Path -Path $configPath)) {
        Write-Error "El archivo de configuración '$configPath' no se encontró."
        return $null
    }

    try {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        return $config
    }
    catch {
        Write-Error "Error al leer o procesar el archivo de configuración '$configPath': $_"
        return $null
    }
}
