<#
.SYNOPSIS
    Obtiene y muestra informaciÃ³n del hardware principal (CPU, RAM, Discos).
.DESCRIPTION
    Usa Get-CimInstance para consultar informaciÃ³n de WMI sobre el procesador,
    la memoria fÃ­sica y los discos lÃ³gicos.
#>
function Get-HardwareInfo {
    Write-Log -Level INFO -Message "Obteniendo informaciÃ³n del hardware." | Out-Null
    
    Write-Host "`n--- CPU ---" -ForegroundColor Cyan
    Get-CimInstance -ClassName Win32_Processor | Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors | ForEach-Object {
        $_.PSObject.Properties | ForEach-Object {
            Write-Host -NoNewline -Object ("- {0,-25}: " -f $_.Name) -ForegroundColor Green
            Write-Host -Object $_.Value -ForegroundColor White
        }
        Write-Host ""
    }
    
    Write-Host "`n--- Memoria RAM ---" -ForegroundColor Cyan
    Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object DeviceLocator, Manufacturer, Speed, @{Name="Capacity(GB)";Expression={[math]::Round($_.Capacity / 1GB, 2)}} | ForEach-Object {
        $_.PSObject.Properties | ForEach-Object {
            Write-Host -NoNewline -Object ("- {0,-25}: " -f $_.Name) -ForegroundColor Green
            Write-Host -Object $_.Value -ForegroundColor White
        }
        Write-Host ""
    }
    $totalMemory = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $freeMemory = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
    Write-Host -NoNewline -Object ("- {0,-25}: " -f "Memoria Total (GB)") -ForegroundColor Green
    Write-Host -Object $totalMemory -ForegroundColor White
    Write-Host -NoNewline -Object ("- {0,-25}: " -f "Memoria Libre (MB)") -ForegroundColor Green
    Write-Host -Object $freeMemory -ForegroundColor White

    Write-Host "`n--- Discos LÃ³gicos ---" -ForegroundColor Cyan
    Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object {
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "DeviceID") -ForegroundColor Green; Write-Host $_.DeviceID -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "VolumeName") -ForegroundColor Green; Write-Host $_.VolumeName -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "FileSystem") -ForegroundColor Green; Write-Host $_.FileSystem -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "Size(GB)") -ForegroundColor Green; Write-Host ([math]::Round($_.Size / 1GB, 2)) -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "FreeSpace(GB)") -ForegroundColor Green; Write-Host ([math]::Round($_.FreeSpace / 1GB, 2)) -ForegroundColor White
        Write-Host ""
    }
}

