<#
.SYNOPSIS
    Ejecuta perfiles o tareas de optimizacion del sistema de forma desatendida.

.DESCRIPTION
    Funcion principal del modulo OptiTech. Permite ejecutar conjuntos de tareas predefinidas (perfiles)
    o tareas individuales para la limpieza, optimizacion y mantenimiento de Windows 11.
    Esta funcion esta disenada para la automatizacion y no requiere interaccion del usuario.

.PARAMETER Profile
    Especifica el nombre de un perfil de ejecucion predefinido en el archivo de configuracion.
    Los perfiles agrupan multiples tareas (ej. 'LimpiezaProfunda').

.PARAMETER Task
    Especifica una o mas tareas individuales a ejecutar. Permite una ejecucion granular
    de las funciones del modulo.

.PARAMETER LogPath
    Especifica una ruta de directorio para guardar el archivo de resumen de ejecucion.
    Si no se especifica, el resumen solo se mostrara en la consola.

.EXAMPLE
    PS C:\> Invoke-OptiTech -Profile LimpiezaProfunda -Verbose
    Ejecuta todas las tareas asociadas al perfil 'LimpiezaProfunda' y muestra informacion detallada.

.EXAMPLE
    PS C:\> Invoke-OptiTech -Task Clear-SystemTempFiles, Clear-UserTempFiles
    Ejecuta unicamente las tareas de limpieza de archivos temporales del sistema y del usuario.

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
        # Inicializar la variable global para los logs de esta ejecucion
        $script:GlobalLogEntries = @()

        # Asegurarse de que el sistema de logging este listo.
        # Initialize-Logging usa $PSScriptRoot del .psm1 para encontrar la carpeta de logs.
        Initialize-Logging

        # Verificar y solicitar elevaciÃ³n de privilegios si es necesario.
        # Nota: Invoke-AdminElevation cerrarÃ¡ el script si no es admin y no puede elevar.
        Invoke-AdminElevation

        Write-Verbose "Inicializando OptiTech. Configurando entorno de ejecucion..."
        $config = Get-OptiTechConfig
        if (-not $config) {
            $script:GlobalLogEntries += (Write-Log -Level ERROR -Message "No se pudo cargar la configuracion. Abortando ejecucion.")
            # Considerar un 'throw' o 'exit' aquÃ­ si la configuraciÃ³n es crÃ­tica.
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
                    $script:GlobalLogEntries += (Write-Log -Level ERROR -Message "El perfil '$Profile' no se encontro en la configuracion. No se ejecutaran tareas.")
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
                        # Capturar la salida de la funcion (los objetos de log)
                        $script:GlobalLogEntries += (& $taskName)
                        $script:GlobalLogEntries += (Write-Log -Level INFO -Message "Tarea '$taskName' completada.")
                    }
                    catch {
                        $script:GlobalLogEntries += (Write-Log -Level ERROR -Message "Error al ejecutar la tarea '$taskName': $($_.Exception.Message)")
                    }
                } else {
                    $script:GlobalLogEntries += (Write-Log -Level WARNING -Message "La tarea '$taskName' no es una funcion valida en el modulo. Omitiendo.")
                }
            }
        }
    }

    end {
        Write-Verbose "Generando resumen de ejecucion..."
        $summaryOutput = Write-OptiTechSummary -LogEntries $script:GlobalLogEntries -OutputPath $LogPath
        
        Write-Verbose "Ejecucion de OptiTech finalizada."
        # Limpiar la variable global para la proxima ejecucion
        $script:GlobalLogEntries = @()
        return $summaryOutput # Devolver el resumen como salida del cmdlet
    }
}

