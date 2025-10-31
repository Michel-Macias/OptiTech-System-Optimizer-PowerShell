@{
    RootModule = "OptiTech.psm1"
    ModuleVersion = "1.0.0"
    Author = "Experto Desarrollador de PowerShell"
    Description = "Módulo de PowerShell para la optimización, limpieza y mantenimiento de sistemas Windows 11."
    FunctionsToExport = @(
        "Invoke-OptiTech"
    )
    PrivateData = @{
        PSData = @{
            ExternalModuleDependencies = @()
        }
    }
}
