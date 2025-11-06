<#
.SYNOPSIS
    Ejecuta una unica tarea de OptiTech y muestra su salida directa.
.DESCRIPTION
    Disenada para el modo interactivo. Esta funcion ejecuta una tarea especifica
    y permite que toda su salida (como texto de Write-Host) se muestre
    directamente en la consola, sin generar un resumen final.
.PARAMETER TaskName
    El nombre de la funcion de la tarea que se va a ejecutar.
.EXAMPLE
    PS C:\> Invoke-OptiTechTask -TaskName Get-OperatingSystemInfo
#>
function Invoke-OptiTechTask {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$TaskName,

        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$AdditionalParameters
    )

    # Busca el comando (la funcion de la tarea) que esta cargado en la sesion actual.
    $taskCommand = Get-Command -Name $TaskName -CommandType Function -ErrorAction SilentlyContinue

    if ($taskCommand) {
        # Si se encuentra el comando, lo invoca con los parametros adicionales.
        # Se usa splatting para pasar los parametros adicionales.
        $paramsToSplat = @{}
        for ($i = 0; $i -lt $AdditionalParameters.Count; $i += 2) {
            $paramName = $AdditionalParameters[$i].TrimStart('-')
            $paramValue = $AdditionalParameters[$i + 1]
            $paramsToSplat.$paramName = $paramValue
        }
        & $taskCommand.ScriptBlock @paramsToSplat
    } else {
        Write-Warning "La tarea '$TaskName' no es una funcion valida en el modulo."
    }
}

