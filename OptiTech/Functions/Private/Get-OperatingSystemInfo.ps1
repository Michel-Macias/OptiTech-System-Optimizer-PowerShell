<#
.SYNOPSIS
    Obtiene y muestra información detallada del sistema operativo.
.DESCRIPTION
    Utiliza el cmdlet Get-ComputerInfo para recopilar datos clave del SO
    y los presenta en un formato de lista.
#>
function Get-OperatingSystemInfo {
    Write-Log -Level INFO -Message "Obteniendo información del sistema operativo." | Out-Null
    
    $osInfo = Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture, CsSystemType, WindowsVersion, WindowsProductName, WindowsCurrentVersion, WindowsInstallationType, OsLanguage, OsCountryCode
    
    $osInfo.PSObject.Properties | ForEach-Object {
        Write-Host -NoNewline -Object ("- {0,-25}: " -f $_.Name) -ForegroundColor Green
        Write-Host -Object $_.Value -ForegroundColor White
    }
}
