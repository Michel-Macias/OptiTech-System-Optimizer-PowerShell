<#
.SYNOPSIS
    Muestra el estado de una lista predefinida de servicios de Windows.
.DESCRIPTION
    Define una lista de servicios importantes o comúnmente problemáticos
    y muestra su estado actual (Running, Stopped, etc.).
#>
function Get-ImportantServicesStatus {
    Write-Log -Level INFO -Message "Obteniendo estado de servicios importantes."
    # Lista de servicios a consultar. Se puede modificar según las necesidades.
    $services = @("Spooler", "wuauserv", "BITS", "SysMain")
    Get-Service -Name $services -ErrorAction SilentlyContinue | Select-Object DisplayName, Name, Status
}
