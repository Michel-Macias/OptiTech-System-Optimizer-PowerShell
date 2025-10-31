# Variable global para la ruta del archivo de log.
$script:LogFilePath = ""

<#
.SYNOPSIS
    Inicializa el sistema de logging.
.DESCRIPTION
    Crea un directorio 'logs' en la misma ubicación que el script si no existe.
    Establece la ruta del archivo de log para la sesión actual con el formato 'OptiTech_yyyy-MM-dd.log'.
#>
function Initialize-Logging {
    $logDir = "$PSScriptRoot/logs"
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory | Out-Null
    }
    $script:LogFilePath = "$logDir/OptiTech_$(Get-Date -Format 'yyyy-MM-dd').log"
}
