<#
.SYNOPSIS
    Genera un resumen de las operaciones realizadas por OptiTech.

.DESCRIPTION
    Esta función toma una colección de objetos de log (generados por Write-Log)
    y crea un resumen ejecutivo de las acciones, el estado y los resultados clave.
    El resumen se puede mostrar en la consola y/o guardar en un archivo.

.PARAMETER LogEntries
    Colección de objetos PSCustomObject devueltos por la función Write-Log,
    que representan todas las entradas de log de la ejecución actual.

.PARAMETER OutputPath
    Ruta completa donde se guardará el archivo de resumen. Si no se especifica,
    el resumen solo se mostrará en la consola.

.OUTPUTS
    [string] - El contenido del resumen generado.
#>
function Write-OptiTechSummary {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$LogEntries,

        [Parameter(Mandatory=$false)]
        [string]$OutputPath
    )

    $summary = New-Object System.Text.StringBuilder
    $summary.AppendLine("--- Resumen de Operaciones OptiTech ---")
    $summary.AppendLine("Fecha y Hora de Ejecución: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $summary.AppendLine("----------------------------------------")

    # Contar acciones por nivel
    $infoCount = ($LogEntries | Where-Object { $_.Level -eq 'INFO' }).Count
    $warningCount = ($LogEntries | Where-Object { $_.Level -eq 'WARNING' }).Count
    $errorCount = ($LogEntries | Where-Object { $_.Level -eq 'ERROR' }).Count

    $summary.AppendLine("Acciones INFO: $infoCount")
    $summary.AppendLine("Advertencias: $warningCount")
    $summary.AppendLine("Errores: $errorCount")
    $summary.AppendLine("")

    # Aquí se podría añadir lógica más compleja para extraer espacio liberado, servicios deshabilitados, etc.
    # Por ahora, un resumen básico de los logs.
    $summary.AppendLine("Detalles de las acciones (últimos 10 mensajes INFO/WARNING/ERROR):")
    $LogEntries | Select-Object -Last 10 | ForEach-Object {
        $summary.AppendLine("  [$($_.Timestamp)] [$($_.Level)] - $($_.Message)")
    }

    $summary.AppendLine("----------------------------------------")
    $summary.AppendLine("Log completo disponible en: $script:LogFilePath")

    $summaryContent = $summary.ToString()

    if (-not [string]::IsNullOrWhiteSpace($OutputPath)) {
        try {
            $summaryFilePath = Join-Path -Path $OutputPath -ChildPath "OptiTech_Summary_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
            $summaryContent | Out-File -FilePath $summaryFilePath -Encoding UTF8
            Write-Log -Level INFO -Message "Resumen de operaciones guardado en: $summaryFilePath"
        }
        catch {
            Write-Log -Level ERROR -Message "No se pudo guardar el resumen en '$OutputPath': $_"
        }
    }

    Write-Host "`n$summaryContent`n"
    return $summaryContent
}
