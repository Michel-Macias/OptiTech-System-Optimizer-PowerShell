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
    # Se utiliza la variable de script definida en el .psm1 para encontrar la raíz del módulo.
    $configPath = Join-Path -Path $script:g_OptiTechRoot -ChildPath 'config.json'

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
