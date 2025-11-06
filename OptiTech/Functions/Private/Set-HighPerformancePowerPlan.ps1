<#
.SYNOPSIS
    Establece el plan de energia de Windows en 'Alto rendimiento'.
.DESCRIPTION
    Busca el GUID del plan de energia 'Alto rendimiento' usando powercfg.exe
    y lo establece como el plan activo.
#>
function Set-HighPerformancePowerPlan {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para cambiar el plan de energia."
        Write-Log -Level ERROR -Message $errorMessage
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Log -Level INFO -Message "Activando el plan de energia de Alto Rendimiento..."
    Write-Host -ForegroundColor White "`nActivando el plan de energia de Alto Rendimiento..."

    try {
        # GUID del plan de energÃ­a de Alto Rendimiento
        $highPerformanceGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
        $currentPlan = powercfg /getactivescheme

        if ($currentPlan -match $highPerformanceGuid) {
            $message = "El plan de energia de Alto Rendimiento ya esta activo."
            Write-Log -Level INFO -Message $message
            Write-Host -ForegroundColor Green "(OK) $message"
            return
        }

        if ($pscmdlet.ShouldProcess("Sistema", "Activar plan de energia de Alto Rendimiento")) {
            powercfg /setactive $highPerformanceGuid
            $message = "Plan de energia de Alto Rendimiento activado."
            Write-Log -Level INFO -Message $message
            Write-Host -ForegroundColor Green "(OK) $message"
        }
    } catch {
        $errorMessage = "Ocurrio un error al intentar activar el plan de energia de Alto Rendimiento."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_"
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        Write-Host -ForegroundColor Red "Asegurate de estar ejecutando el script como Administrador."
    }
}

