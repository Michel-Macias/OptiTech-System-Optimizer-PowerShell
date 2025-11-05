<#
.SYNOPSIS
    Detiene y deshabilita una lista de servicios no esenciales definida en la configuración.
.DESCRIPTION
    Carga la lista de servicios desde el archivo config.json. Recorre la lista y,
    si los servicios existen, los detiene y establece su tipo de inicio en 'Deshabilitado'.
#>
function Manage-NonEssentialServices {
    Write-Log -Level INFO -Message "Gestionando servicios no esenciales según la configuración..."
    
    $config = Get-OptiTechConfig
    if (-not $config -or -not $config.PSObject.Properties.Name -contains 'ServicesToDisable') {
        Write-Log -Level WARNING -Message "No se encontró una configuración válida o la lista 'ServicesToDisable' en config.json. Omitiendo tarea."
        return
    }

    $servicesToDisable = $config.ServicesToDisable
    
    foreach ($service in $servicesToDisable) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Log -Level INFO -Message "Servicio $service deshabilitado y detenido."
        } else {
            Write-Log -Level WARNING -Message "El servicio '$service' (definido en config.json) no se encontró."
        }
    }
}
