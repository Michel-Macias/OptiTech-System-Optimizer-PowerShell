# Ruta raíz del módulo
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Cargar todas las funciones privadas y públicas de forma recursiva
Get-ChildItem -Path "$PSScriptRoot\Functions" -Filter "*.ps1" -Recurse | ForEach-Object {
    . $_.FullName
}

# Exportar explícitamente solo las funciones públicas para el usuario final
Export-ModuleMember -Function 'Invoke-OptiTech'
