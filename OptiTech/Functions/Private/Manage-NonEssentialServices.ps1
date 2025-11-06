<#
.SYNOPSIS
    Detiene y deshabilita una lista de servicios no esenciales definida en la configuracion.
.DESCRIPTION
    Carga la lista de servicios desde el archivo config.json. Recorre la lista y,
    si los servicios existen, los detiene y establece su tipo de inicio en 'Deshabilitado'.
#>
function Manage-NonEssentialServices {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Disable', 'Restore')]
        [string]$Action
    )

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para gestionar los servicios."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    $logMessage = if ($Action -eq 'Disable') {
        "Deshabilitando servicios no esenciales..."
    } else {
        "Restaurando el tipo de inicio original de los servicios..."
    }
    Write-Log -Level INFO -Message $logMessage | Out-Null
    Write-Host -ForegroundColor White "$logMessage"

    $servicesToProcess = Get-OptiTechConfig -Section 'ServicesToDisable'
    if (-not $servicesToProcess) {
        $errorMessage = "No se pudo cargar la lista de servicios a deshabilitar/restaurar desde la configuracion."
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    foreach ($serviceName in $servicesToProcess) {
        $currentService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

        if (-not $currentService) {
            Write-Log -Level WARNING -Message "El servicio '$serviceName' no se encontro en el sistema." | Out-Null
            continue
        }

        $targetStartupType = if ($Action -eq 'Disable') { 'Disabled' } else { 'Automatic' } # Asumimos Automatic para restaurar

        if ($currentService.StartType -eq $targetStartupType) {
            $message = "El servicio '$serviceName' ya esta en el estado deseado ('$targetStartupType')."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Gray "- $message"
            continue
        }

        if ($pscmdlet.ShouldProcess($serviceName, "Cambiar tipo de inicio a $targetStartupType")) {
            try {
                Set-Service -Name $serviceName -StartupType $targetStartupType -ErrorAction Stop
                $message = "Servicio '$serviceName' configurado como '$targetStartupType'."
                Write-Log -Level INFO -Message $message | Out-Null
                Write-Host -ForegroundColor Green "  (OK) $message"
            } catch {
                $errorMessage = "No se pudo cambiar el tipo de inicio del servicio '$serviceName'."
                Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
                Write-Host -ForegroundColor Red "  (ERROR) $errorMessage"
            }
        }
    }

    $finalMessage = "Gestion de servicios no esenciales completada."
    Write-Log -Level INFO -Message $finalMessage | Out-Null
    Write-Host -ForegroundColor Green "(OK) $finalMessage"
}

