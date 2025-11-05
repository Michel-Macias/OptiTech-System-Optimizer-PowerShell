<#
.SYNOPSIS
    Detiene y deshabilita una lista de servicios no esenciales definida en la configuración.
.DESCRIPTION
    Carga la lista de servicios desde el archivo config.json. Recorre la lista y,
    si los servicios existen, los detiene y establece su tipo de inicio en 'Deshabilitado'.
#>
function Manage-NonEssentialServices {
    Write-Log -Level INFO -Message "Iniciando gestión de servicios no esenciales..." | Out-Null
    Write-Host -ForegroundColor White "`nGestionando servicios no esenciales según la configuración..."

    $config = Get-OptiTechConfig
    if (-not $config -or -not $config.PSObject.Properties.Name -contains 'ServicesToDisable') {
        $warningMessage = "No se encontró una configuración válida o la lista 'ServicesToDisable' en config.json. Omitiendo tarea."
        Write-Log -Level WARNING -Message $warningMessage | Out-Null
        Write-Host -ForegroundColor Yellow "- $warningMessage"
        return
    }

    $servicesToDisable = $config.ServicesToDisable
    
    foreach ($service in $servicesToDisable) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            try {
                Stop-Service -Name $service -Force -ErrorAction Stop
                Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
                $message = "Servicio '$service' deshabilitado y detenido."
                Write-Log -Level INFO -Message $message | Out-Null
                Write-Host -ForegroundColor Green "- $message"
            }
            catch {
                $errorMessage = "No se pudo detener o deshabilitar el servicio '$service'. Puede que requiera permisos elevados."
                Write-Log -Level ERROR -Message "$errorMessage Error: $_" | Out-Null
                Write-Host -ForegroundColor Red "- $errorMessage"
            }
        } else {
            $warningMessage = "El servicio '$service' (definido en config.json) no se encontró."
            Write-Log -Level WARNING -Message $warningMessage | Out-Null
            Write-Host -ForegroundColor Yellow "- $warningMessage"
        }
    }
    Write-Host -ForegroundColor Green "`n✔ Gestión de servicios no esenciales completada."
}
