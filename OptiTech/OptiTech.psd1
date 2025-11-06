@{
    RootModule = "OptiTech.psm1"
    ModuleVersion = "1.0.0"
    Author = "Experto Desarrollador de PowerShell"
    Description = "Modulo de PowerShell para la optimización, limpieza y mantenimiento de sistemas Windows 11."
    FunctionsToExport = @(
        "Clear-SystemTempFiles",
        "Clear-TeamsCache",
        "Clear-UpdateCache",
        "Clear-UserTempFiles",
        "Clear-WinSxSComponent",
        "Disable-Hibernation",
        "Flush-DnsCache",
        "Get-HardwareInfo",
        "Get-ImportantServicesStatus",
        "Get-OperatingSystemInfo",
        "Get-OptiTechConfig",
        "Initialize-Logging",
        "Invoke-AdminElevation",
        "Invoke-ClearRecycleBin",
        "Manage-NonEssentialServices",
        "New-RegistryBackup",
        "New-SystemRestorePoint",
        "Remove-SystemRestorePoints",
        "Renew-IpAddress",
        "Restore-RegistryBackup",
        "Run-DISMScan",
        "Run-SFCScan",
        "Set-HighPerformancePowerPlan",
        "Set-PerformanceVisualEffects",
        "Start-ChkdskScan",
        "Test-IsAdmin",
        "Write-Log",
        "Write-OptiTechSummary",
        "Invoke-OptiTech",
        "Invoke-OptiTechTask"
    )
    NestedModules = @(
        ".\Functions\Private\Clear-SystemTempFiles.ps1",
        ".\Functions\Private\Clear-TeamsCache.ps1",
        ".\Functions\Private\Clear-UpdateCache.ps1",
        ".\Functions\Private\Clear-UserTempFiles.ps1",
        ".\Functions\Private\Clear-WinSxSComponent.ps1",
        ".\Functions\Private\Disable-Hibernation.ps1",
        ".\Functions\Private\Flush-DnsCache.ps1",
        ".\Functions\Private\Get-HardwareInfo.ps1",
        ".\Functions\Private\Get-ImportantServicesStatus.ps1",
        ".\Functions\Private\Get-OperatingSystemInfo.ps1",
        ".\Functions\Private\Get-OptiTechConfig.ps1",
        ".\Functions\Private\Initialize-Logging.ps1",
        ".\Functions\Private\Invoke-AdminElevation.ps1",
        ".\Functions\Private\Invoke-ClearRecycleBin.ps1",
        ".\Functions\Private\Manage-NonEssentialServices.ps1",
        ".\Functions\Private\New-RegistryBackup.ps1",
        ".\Functions\Private\New-SystemRestorePoint.ps1",
        ".\Functions\Private\Remove-SystemRestorePoints.ps1",
        ".\Functions\Private\Renew-IpAddress.ps1",
        ".\Functions\Private\Restore-RegistryBackup.ps1",
        ".\Functions\Private\Run-DISMScan.ps1",
        ".\Functions\Private\Run-SFCScan.ps1",
        ".\Functions\Private\Set-HighPerformancePowerPlan.ps1",
        ".\Functions\Private\Set-PerformanceVisualEffects.ps1",
        ".\Functions\Private\Start-ChkdskScan.ps1",
        ".\Functions\Private\Test-IsAdmin.ps1",
        ".\Functions\Private\Write-Log.ps1",
        ".\Functions\Private\Write-OptiTechSummary.ps1",
        ".\Functions\Public\Invoke-OptiTech.ps1",
        ".\Functions\Public\Invoke-OptiTechTask.ps1"
    )
    PrivateData = @{
        PSData = @{
            ExternalModuleDependencies = @()
        }
    }
}
