<#
.SYNOPSIS
    Establece el plan de energía de Windows en 'Alto rendimiento'.
.DESCRIPTION
    Busca el GUID del plan de energía 'Alto rendimiento' usando powercfg.exe
    y lo establece como el plan activo.
#>
function Set-HighPerformancePowerPlan {
    Write-Log -Level INFO -Message "Iniciando aplicación del plan de energía de alto rendimiento..." | Out-Null
    Write-Host -ForegroundColor White "`nAplicando plan de energía de alto rendimiento..."

    try {
        # Busca la línea que contiene "Alto rendimiento" y extrae el GUID.
        $highPerformance = powercfg /list | Where-Object { $_ -match "Alto rendimiento" } | ForEach-Object { ($_.Split(" "))[3] }
        if ($highPerformance) {
            powercfg /setactive $highPerformance
            if ($LASTEXITCODE -ne 0) { throw "powercfg.exe /setactive falló." }
            $message = "Plan de energía de alto rendimiento activado."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "✔ $message"
        } else {
            $warningMessage = "No se encontró el plan de energía de alto rendimiento."
            Write-Log -Level WARNING -Message $warningMessage | Out-Null
            Write-Host -ForegroundColor Yellow "- $warningMessage"
        }
    }
    catch {
        $errorMessage = "Ocurrió un error al aplicar el plan de energía: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
        Write-Host -ForegroundColor Red "Asegúrate de estar ejecutando el script como Administrador."
    }
}
