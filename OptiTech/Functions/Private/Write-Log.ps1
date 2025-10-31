<#
.SYNOPSIS
    Escribe un mensaje en el archivo de log y en la consola, y devuelve un objeto de log.
.PARAMETER Message
    El mensaje que se va a registrar.
.PARAMETER Level
    El nivel del mensaje (INFO, WARNING, ERROR). Determina el color en la consola.
.OUTPUTS
    [PSCustomObject] - Un objeto que representa la entrada de log.
#>
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] - $Message"
    
    # Añade la entrada al archivo de log.
    Add-Content -Path $script:LogFilePath -Value $logEntry

    # Muestra la entrada en la consola con un color distintivo según el nivel.
    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
    }
    Write-Host $logEntry -ForegroundColor $color

    # Devuelve un objeto de log para el motor de informes.
    return [PSCustomObject]@{
        Timestamp = $timestamp
        Level     = $Level
        Message   = $Message
    }
}
