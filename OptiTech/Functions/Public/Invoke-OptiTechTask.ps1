<#
.SYNOPSIS
    Ejecuta una única tarea de OptiTech y muestra su salida directa.
.DESCRIPTION
    Diseñada para el modo interactivo. Esta función ejecuta una tarea específica
    y permite que toda su salida (como texto de Write-Host) se muestre
    directamente en la consola, sin generar un resumen final.
.PARAMETER TaskName
    El nombre de la función de la tarea que se va a ejecutar.
.EXAMPLE
    PS C:\> Invoke-OptiTechTask -TaskName Get-OperatingSystemInfo
#>
function Invoke-OptiTechTask {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )

    # Busca el comando (la función de la tarea) que está cargado en la sesión actual.
    $taskCommand = Get-Command -Name $TaskName -CommandType Function -ErrorAction SilentlyContinue

    if ($taskCommand) {
        # Si se encuentra el comando, lo invoca.
        & $taskCommand.ScriptBlock
    } else {
        Write-Warning "La tarea '$TaskName' no es una función válida en el módulo."
    }
}
