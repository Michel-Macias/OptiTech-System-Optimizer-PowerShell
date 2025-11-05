<#
.SYNOPSIS
    Muestra el estado de una lista predefinida de servicios de Windows.
.DESCRIPTION
    Define una lista de servicios importantes o comúnmente problemáticos
    y muestra su estado actual (Running, Stopped, etc.).
#>
function Get-ImportantServicesStatus {
    Write-Log -Level INFO -Message "Obteniendo estado de servicios importantes." | Out-Null
    # Lista de servicios a consultar. Se puede modificar según las necesidades.
    $services = @("Spooler", "wuauserv", "BITS", "SysMain")
    $serviceStatus = Get-Service -Name $services -ErrorAction SilentlyContinue

    if ($serviceStatus) {
        Write-Host "`n--- Estado de Servicios Importantes ---" -ForegroundColor Cyan
        $serviceStatus | ForEach-Object {
            Write-Host -NoNewline -Object ("- {0,-25}: " -f "DisplayName") -ForegroundColor Green; Write-Host $_.DisplayName -ForegroundColor White
            Write-Host -NoNewline -Object ("- {0,-25}: " -f "Name") -ForegroundColor Green; Write-Host $_.Name -ForegroundColor White
            
            $statusColor = if ($_.Status -eq 'Running') { 'Green' } else { 'Red' }
            Write-Host -NoNewline -Object ("- {0,-25}: " -f "Status") -ForegroundColor Green; Write-Host $_.Status -ForegroundColor $statusColor
            Write-Host ""
        }
    }
}
