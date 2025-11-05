# Ruta raíz del módulo, guardada en una variable de script para que sea accesible por todas las funciones.
$script:g_OptiTechRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Cargar todas las funciones privadas y públicas de forma recursiva
Get-ChildItem -Path "$script:g_OptiTechRoot\Functions" -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}

# Exportar explícitamente solo las funciones públicas para el usuario final
Export-ModuleMember -Function 'Invoke-OptiTech'
