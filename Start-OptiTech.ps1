<#
.SYNOPSIS
    Lanzador interactivo para el módulo OptiTech System Optimizer.
.DESCRIPTION
    Este script proporciona una interfaz de menú de consola para ejecutar las
    tareas de optimización, limpieza y mantenimiento del módulo OptiTech.
    Actúa como una envoltura amigable para el usuario alrededor del cmdlet
    principal Invoke-OptiTech.
.AUTHOR
    Equipo de Desarrollo IA (con unificación de Gemini)
#>

# --- INICIALIZACIÓN Y VERIFICACIÓN ---

# Forzar la importación del módulo local OptiTech.
# La ruta asume que el script se ejecuta desde la raíz del proyecto.
try {
    Import-Module -Name ".\OptiTech" -Force -ErrorAction Stop
}
catch {
    Write-Host -ForegroundColor Red "Error Crítico: No se pudo importar el módulo OptiTech."
    Write-Host -ForegroundColor Red "Asegúrese de que el directorio 'OptiTech' se encuentra en la misma carpeta que este script."
    Read-Host "Presione Enter para salir."
    exit
}

# --- FUNCIONES DE MENÚ (ADAPTADAS) ---

#region Menús Interactivos

function Show-AnalysisMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Análisis ---" -ForegroundColor Cyan
        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Información del Sistema Operativo"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Información del Hardware"
        Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Estado de Servicios Importantes"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        # En el módulo de análisis, las tareas son de solo lectura.
        switch ($choice) {
            '1' { Invoke-OptiTechTask -TaskName Get-OperatingSystemInfo }
            '2' { Invoke-OptiTechTask -TaskName Get-HardwareInfo }
            '3' { Invoke-OptiTechTask -TaskName Get-ImportantServicesStatus }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

function Show-CleanupMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Limpieza ---" -ForegroundColor Cyan

        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Limpiar archivos temporales del sistema"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Limpiar archivos temporales del usuario"
        Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Vaciar la papelera de reciclaje"
        Write-Host -NoNewline "4. " -ForegroundColor Yellow; Write-Host "Revisar puntos de restauración"
        Write-Host -NoNewline "5. " -ForegroundColor Yellow; Write-Host "Limpiar caché de Windows Update"
        Write-Host -NoNewline "6. " -ForegroundColor Yellow; Write-Host "Desactivar hibernación (libera mucho espacio)"
        Write-Host -NoNewline "7. " -ForegroundColor Yellow; Write-Host "Limpiar componentes de Windows (WinSxS)"
        Write-Host -NoNewline "8. " -ForegroundColor Yellow; Write-Host "Limpiar caché de Microsoft Teams"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Invoke-OptiTechTask -TaskName Clear-SystemTempFiles }
            '2' { Invoke-OptiTechTask -TaskName Clear-UserTempFiles }
            '3' { Invoke-OptiTechTask -TaskName Invoke-ClearRecycleBin }
            '4' { Invoke-OptiTechTask -TaskName Remove-SystemRestorePoints } # El nombre se mantiene por consistencia
            '5' { Invoke-OptiTechTask -TaskName Clear-UpdateCache }
            '6' { Invoke-OptiTechTask -TaskName Disable-Hibernation }
            '7' { Invoke-OptiTechTask -TaskName Clear-WinSxSComponent }
            '8' { Invoke-OptiTechTask -TaskName Clear-TeamsCache }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

function Show-OptimizationMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Optimización ---" -ForegroundColor Cyan

        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Ajustar efectos visuales para mejor rendimiento"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Gestionar servicios no esenciales"
        Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Aplicar plan de energía de alto rendimiento"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Invoke-OptiTechTask -TaskName Set-PerformanceVisualEffects }
            '2' { Invoke-OptiTechTask -TaskName Manage-NonEssentialServices }
            '3' { Invoke-OptiTechTask -TaskName Set-HighPerformancePowerPlan }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

function Show-MaintenanceMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Mantenimiento y Copias de Seguridad ---" -ForegroundColor Cyan

        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Crear punto de restauración del sistema"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Ejecutar 'sfc /scannow'"
        Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Ejecutar 'DISM /Online /Cleanup-Image /RestoreHealth'"
        Write-Host -NoNewline "4. " -ForegroundColor Yellow; Write-Host "Crear copia de seguridad del Registro"
        Write-Host -NoNewline "5. " -ForegroundColor Yellow; Write-Host "Restaurar copia de seguridad del Registro (Alto Riesgo)"
        Write-Host -NoNewline "6. " -ForegroundColor Yellow; Write-Host "Programar comprobación de disco (chkdsk)"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Invoke-OptiTechTask -TaskName New-SystemRestorePoint }
            '2' { Invoke-OptiTechTask -TaskName Run-SFCScan }
            '3' { Invoke-OptiTechTask -TaskName Run-DISMScan }
            '4' { Invoke-OptiTechTask -TaskName New-RegistryBackup }
            '5' { Invoke-OptiTechTask -TaskName Restore-RegistryBackup } # Esta tarea ya tiene confirmaciones internas
            '6' { Invoke-OptiTechTask -TaskName Start-ChkdskScan }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

function Show-NetworkMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Red y Conectividad ---" -ForegroundColor Cyan

        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Limpiar la caché de DNS (flushdns)"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Renovar la dirección IP (renew)"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Invoke-OptiTechTask -TaskName Flush-DnsCache }
            '2' { Invoke-OptiTechTask -TaskName Renew-IpAddress }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

function Show-ProfilesMenu {
    $config = Get-OptiTechConfig # Esta función ahora viene del módulo
    if (-not $config -or -not $config.Profiles) {
        Write-Warning "No se encontraron perfiles en config.json. Abortando."
        Read-Host "Presione Enter para continuar..."
        return
    }

    $profileNames = $config.Profiles.PSObject.Properties.Name
    if ($profileNames.Count -eq 0) {
        Write-Warning "No hay perfiles definidos en config.json."
        Read-Host "Presione Enter para continuar..."
        return
    }

    while ($true) {
        Clear-Host
        Write-Host "--- Seleccionar Perfil Automatizado ---" -ForegroundColor Cyan
        Write-Host "Los perfiles se ejecutarán en modo 'WhatIf' (simulación). No se realizarán cambios." -ForegroundColor Magenta
        Write-Host "Para ejecutar los cambios, edite este script y elimine el parámetro '-WhatIf'." -ForegroundColor Magenta
        for ($i = 0; $i -lt $profileNames.Count; $i++) {
            Write-Host -NoNewline ("{0}. " -f ($i + 1)) -ForegroundColor Yellow; Write-Host $profileNames[$i]
        }
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

        $choice = Read-Host "Seleccione un perfil para ejecutar"

        if ($choice -eq 'V') { return }

        if ($choice -match '^\d+$' -and ([int]$choice -gt 0) -and ([int]$choice -le $profileNames.Count)) {
            $selectedProfileName = $profileNames[[int]$choice - 1]
            
            Invoke-OptiTech -Profile $selectedProfileName -WhatIf

            Read-Host "Presione Enter para continuar..."
            return
        } else {
            Write-Warning "Opción no válida. Por favor, intente de nuevo."
            Read-Host "Presione Enter para continuar..."
        }
    }
}

#endregion

# --- BUCLE PRINCIPAL DEL MENÚ ---

while ($true) {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   OptiTech System Optimizer (Menú Interactivo)" -ForegroundColor Cyan
    Write-Host "   (Motor: Módulo OptiTech v1.0.0)" -ForegroundColor DarkCyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host
    Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Análisis del Sistema"
    Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Limpieza del Sistema"
    Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Optimización del Sistema"
    Write-Host -NoNewline "4. " -ForegroundColor Yellow; Write-Host "Mantenimiento y Copias de Seguridad"
    Write-Host -NoNewline "5. " -ForegroundColor Yellow; Write-Host "Red y Conectividad"
    Write-Host
    Write-Host -NoNewline "A. " -ForegroundColor Yellow; Write-Host "Ejecutar Perfil Automatizado (Modo Simulación)"
    Write-Host
    Write-Host -NoNewline "S. " -ForegroundColor Yellow; Write-Host "Salir"
    Write-Host

    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        '1' { Show-AnalysisMenu }
        '2' { Show-CleanupMenu }
        '3' { Show-OptimizationMenu }
        '4' { Show-MaintenanceMenu }
        '5' { Show-NetworkMenu }
        'A' { Show-ProfilesMenu }
        'S' {
            Write-Host "Saliendo de OptiTech System Optimizer."
            break
        }
        default {
            Write-Warning "Opción no válida. Por favor, intente de nuevo."
        }
    }
}
