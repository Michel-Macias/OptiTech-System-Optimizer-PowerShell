<#
.SYNOPSIS
    Establece el plan de energía de Windows en 'Alto rendimiento'.
.DESCRIPTION
    Busca el GUID del plan de energía 'Alto rendimiento' usando powercfg.exe
    y lo establece como el plan activo.
#>
function Set-HighPerformancePowerPlan {
    Write-Log -Level INFO -Message "Aplicando plan de energía de alto rendimiento..."
    # Busca la línea que contiene "Alto rendimiento" y extrae el GUID.
    $highPerformance = powercfg /list | Where-Object { $_ -match "Alto rendimiento" } | ForEach-Object { ($_.Split(" "))[3] }
    if ($highPerformance) {
        powercfg /setactive $highPerformance
        Write-Log -Level INFO -Message "Plan de energía de alto rendimiento activado."
    } else {
        Write-Log -Level WARNING -Message "No se encontró el plan de energía de alto rendimiento."
    }
}
