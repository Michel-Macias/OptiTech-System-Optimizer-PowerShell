<#
.SYNOPSIS
    Detiene y deshabilita una lista predefinida de servicios no esenciales.
.DESCRIPTION
    Recorre una lista de nombres de servicios y, si existen, los detiene
    y establece su tipo de inicio en 'Deshabilitado'.
#>
function Manage-NonEssentialServices {
    Write-Log -Level INFO -Message "Gestionando servicios no esenciales..."
    # Lista de servicios a deshabilitar. Añadir o quitar según sea necesario.
    # 'dmwappushservice': Servicio de enrutamiento de mensajes push de WAP del dispositivo.
    # 'diagtrack': Experiencias de usuario y telemetría asociadas.
    $servicesToDisable = @("dmwappushservice", "diagtrack")
    foreach ($service in $servicesToDisable) {
        if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Log -Level INFO -Message "Servicio $service deshabilitado y detenido."
        } else {
            Write-Log -Level WARNING -Message "El servicio $service no se encontró."
        }
    }
}
