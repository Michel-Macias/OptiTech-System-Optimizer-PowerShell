<#
.SYNOPSIS
    Ejecuta perfiles o tareas de optimización del sistema de forma desatendida.

.DESCRIPTION
    Función principal del módulo OptiTech. Permite ejecutar conjuntos de tareas predefinidas (perfiles)
    o tareas individuales para la limpieza, optimización y mantenimiento de Windows 11.
    Esta función está diseñada para la automatización y no requiere interacción del usuario.

.PARAMETER Profile
    Especifica el nombre de un perfil de ejecución predefinido en el archivo de configuración.
    Los perfiles agrupan múltiples tareas (ej. 'LimpiezaProfunda').

.PARAMETER Task
    Especifica una o más tareas individuales a ejecutar. Permite una ejecución granular
    de las funciones del módulo.

.PARAMETER LogPath
    Especifica una ruta de directorio para guardar el archivo de resumen de ejecución.
    Si no se especifica, el resumen solo se mostrará en la consola.

.EXAMPLE
    PS C:\> Invoke-OptiTech -Profile LimpiezaProfunda -Verbose
    Ejecuta todas las tareas asociadas al perfil 'LimpiezaProfunda' y muestra información detallada.

.EXAMPLE
    PS C:\> Invoke-OptiTech -Task Clear-SystemTempFiles, Clear-UserTempFiles
    Ejecuta únicamente las tareas de limpieza de archivos temporales del sistema y del usuario.

.OUTPUTS
    [PSCustomObject] - Un objeto PSCustomObject con el resumen de todas las operaciones realizadas.
#>
function Invoke-OptiTech {
    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Profile')]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(ParameterSetName = 'Profile', Mandatory = $true, Position = 0)]
        [string]$Profile,

        [Parameter(ParameterSetName = 'Task', Mandatory = $true, Position = 0)]
        [string[]]$Task,

        [Parameter(ParameterSetName = 'Profile')]
        [Parameter(ParameterSetName = 'Task')]
        [string]$LogPath
    )

    begin {
        # Inicializar la variable global para los logs de esta ejecución
        $script:GlobalLogEntries = @()

        # Asegurarse de que el sistema de logging esté listo.
        # Initialize-Logging usa $PSScriptRoot del .psm1 para encontrar la carpeta de logs.
        Initialize-Logging

        # Verificar y solicitar elevación de privilegios si es necesario.
        # Nota: Invoke-AdminElevation cerrará el script si no es admin y no puede elevar.
        Invoke-AdminElevation

        Write-Verbose "Inicializando OptiTech. Configurando entorno de ejecución..."
        $config = Get-OptiTechConfig
        if (-not $config) {
            $script:GlobalLogEntries += (Write-Log -Level ERROR -Message "No se pudo cargar la configuración. Abortando ejecución.")
            # Considerar un 'throw' o 'exit' aquí si la configuración es crítica.
            # Por ahora, permitimos que el bloque 'process' maneje la ausencia de config.
        }
    }

    process {
        if ($PSCmdlet.ShouldProcess("sistema", "Aplicar optimizaciones de OptiTech")) {
            Write-Verbose "Procesando tareas..."
            $tasksToExecute = @()

            if ($PSCmdlet.ParameterSetName -eq 'Profile') {
                if ($config -and $config.Profiles.$Profile) {
                    $tasksToExecute = $config.Profiles.$Profile
                    $script:GlobalLogEntries += (Write-Log -Level INFO -Message "Ejecutando perfil: '$Profile'")
                } else {
                    $script:GlobalLogEntries += (Write-Log -Level ERROR -Message "El perfil '$Profile' no se encontró en la configuración. No se ejecutarán tareas.")
                    return
                }
            } elseif ($PSCmdlet.ParameterSetName -eq 'Task') {
                $tasksToExecute = $Task
                $script:GlobalLogEntries += (Write-Log -Level INFO -Message "Ejecutando tareas individuales: $($Task -join ', ')")
            }

            foreach ($taskName in $tasksToExecute) {
                Write-Verbose "Ejecutando tarea: $taskName"
                if (Get-Command -Name $taskName -CommandType Function -ErrorAction SilentlyContinue) {
                    try {
                        # Capturar la salida de la función (los objetos de log)
                        $script:GlobalLogEntries += (& $taskName)
                        $script:GlobalLogEntries += (Write-Log -Level INFO -Message "Tarea '$taskName' completada.")
                    }
                    catch {
                        $script:GlobalLogEntries += (Write-Log -Level ERROR -Message "Error al ejecutar la tarea '$taskName': $($_.Exception.Message)")
                    }
                } else {
                    $script:GlobalLogEntries += (Write-Log -Level WARNING -Message "La tarea '$taskName' no es una función válida en el módulo. Omitiendo.")
                }
            }
        }
    }

    end {
        Write-Verbose "Generando resumen de ejecución..."
        $summaryOutput = Write-OptiTechSummary -LogEntries $script:GlobalLogEntries -OutputPath $LogPath
        
        Write-Verbose "Ejecución de OptiTech finalizada."
        # Limpiar la variable global para la próxima ejecución
        $script:GlobalLogEntries = @()
        return $summaryOutput # Devolver el resumen como salida del cmdlet
    }
}
