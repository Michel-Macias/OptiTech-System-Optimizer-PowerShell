<#
.SYNOPSIS
    Obtiene y muestra información del hardware principal (CPU, RAM, Discos).
.DESCRIPTION
    Usa Get-CimInstance para consultar información de WMI sobre el procesador,
    la memoria física y los discos lógicos.
#>
function Get-HardwareInfo {
    Write-Log -Level INFO -Message "Obteniendo información del hardware."
    
    Write-Host "--- CPU ---"
    Get-CimInstance -ClassName Win32_Processor | Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors
    
    Write-Host "--- Memoria RAM ---"
    Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object Capacity, Manufacturer, Speed
    $totalMemory = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $freeMemory = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
    Write-Host "Memoria Total: $totalMemory GB"
    Write-Host "Memoria Libre: $freeMemory MB"

    Write-Host "--- Discos Lógicos ---"
    Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, @{Name="Size(GB)";Expression={[math]::Round($_.Size / 1GB, 2)}}, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}}
}
