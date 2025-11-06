# Ruta raíz del módulo, guardada en una variable de script para que sea accesible por todas las funciones.
$script:g_OptiTechRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Inicializar el sistema de logging para que este disponible para todas las funciones.
Initialize-Logging
Initialize-Logging
