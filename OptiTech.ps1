$OutputEncoding = [System.Text.Encoding]::UTF8
<#
.SYNOPSIS
    OptiTech System Optimizer - Herramienta de optimización para Windows 11.

.DESCRIPTION
    Este script contiene todas las funcionalidades de OptiTech System Optimizer
    para una ejecución rápida y directa.

.AUTHOR
    Equipo de Desarrollo IA
#>

# --- FUNCIONES DE UTILIDAD ---

<#
.SYNOPSIS
    Verifica si el script se está ejecutando con privilegios de administrador.
.DESCRIPTION
    Intenta acceder a una clave del registro en HKLM que requiere elevación.
    Si tiene éxito, devuelve $true; de lo contrario, captura la excepción y devuelve $false.
.OUTPUTS
    [bool] - $true si es administrador, $false en caso contrario.
#>
function Test-IsAdmin {
    try {
        # Intenta leer una clave de registro que solo los administradores pueden leer.
        Get-Item -Path "HKLM:\SOFTWARE\Microsoft" -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        # Si se produce un error de acceso, no es administrador.
        return $false
    }
}

<#
.SYNOPSIS
    Solicita la elevación de privilegios si el script no se está ejecutando como administrador.
.DESCRIPTION
    Comprueba si el usuario es administrador usando Test-IsAdmin. Si no lo es,
    reinicia el script actual en una nueva ventana de PowerShell con privilegios elevados
    y cierra el script actual.
#>
function Invoke-AdminElevation {
    if (-not (Test-IsAdmin)) {
        try {
            # Parámetros para iniciar un nuevo proceso de PowerShell con el script actual.
            $params = @{
                FilePath = $psCommandPath # Ruta del script actual.
                Verb = "RunAs" # Indica que se debe ejecutar como administrador.
                ErrorAction = "Stop"
            }
            Start-Process @params
        }
        catch {
            Write-Warning "Error al intentar elevar privilegios: $_"
        }
        # Cierra el script actual para evitar que continúe sin privilegios.
        exit
    }
}

# Variable global para la ruta del archivo de log.
$script:LogFilePath = ""

<#
.SYNOPSIS
    Inicializa el sistema de logging.
.DESCRIPTION
    Crea un directorio 'logs' en la misma ubicación que el script si no existe.
    Establece la ruta del archivo de log para la sesión actual con el formato 'OptiTech_yyyy-MM-dd.log'.
#>
function Initialize-Logging {
    $logDir = "$PSScriptRoot/logs"
    if (-not (Test-Path -Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory | Out-Null
    }
    $script:LogFilePath = "$logDir/OptiTech_$(Get-Date -Format 'yyyy-MM-dd').log"
}

<#
.SYNOPSIS
    Escribe un mensaje en el archivo de log y en la consola, y devuelve un objeto de log.
.PARAMETER Message
    El mensaje que se va a registrar.
.PARAMETER Level
    El nivel del mensaje (INFO, WARNING, ERROR). Determina el color en la consola.
.OUTPUTS
    [PSCustomObject] - Un objeto que representa la entrada de log.
#>
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$Level
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logEntry = "[$timestamp] [$Level] - $Message"
    
    # Añade la entrada al archivo de log.
    Add-Content -Path $script:LogFilePath -Value $logEntry

    # Muestra la entrada en la consola con un color distintivo según el nivel.
    $color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
    }
    Write-Host $logEntry -ForegroundColor $color

    # Devuelve un objeto de log para el motor de informes.
    return [PSCustomObject]@{
        Timestamp = $timestamp
        Level     = $Level
        Message   = $Message
    }
}

<#
.SYNOPSIS
    Carga la configuración desde el archivo config.json.
.DESCRIPTION
    Lee el archivo config.json ubicado en la misma carpeta que el script, lo convierte
    desde formato JSON a un objeto de PowerShell y lo devuelve.
.OUTPUTS
    [PSCustomObject] - El objeto de configuración.
#>
function Get-OptiTechConfig {
    $configPath = Join-Path -Path $PSScriptRoot -ChildPath 'config.json'

    if (-not (Test-Path -Path $configPath)) {
        Write-Warning "El archivo de configuración '$configPath' no se encontró. Se usará la configuración por defecto."
        return $null # O devolver una configuración por defecto si se desea
    }

    try {
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        return $config
    }
    catch {
        Write-Warning "Error al leer o procesar el archivo de configuración '$configPath': $_"
        return $null
    }
}

# --- FUNCIONES DE LOS MÓDulos ---

#region Análisis

<#
.SYNOPSIS
    Obtiene y muestra información detallada del sistema operativo.
.DESCRIPTION
    Utiliza el cmdlet Get-ComputerInfo para recopilar datos clave del SO
    y los presenta en un formato de lista.
#>
function Get-OperatingSystemInfo {
    Write-Log -Level INFO -Message "Obteniendo información del sistema operativo."
    Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture, CsSystemType, WindowsVersion, WindowsProductName, WindowsCurrentVersion, WindowsInstallationType, OsLanguage, OsCountryCode | Out-Host
}

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
    Get-CimInstance -ClassName Win32_Processor | Select-Object Name, Manufacturer, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors | Out-Host
    
    Write-Host "--- Memoria RAM ---"
    Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object Capacity, Manufacturer, Speed | Out-Host
    $totalMemory = [math]::Round((Get-CimInstance -ClassName Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
    $freeMemory = [math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)
    Write-Host "Memoria Total: $totalMemory GB"
    Write-Host "Memoria Libre: $freeMemory MB"

    Write-Host "--- Discos Lógicos ---"
    Get-CimInstance -ClassName Win32_LogicalDisk | Select-Object DeviceID, VolumeName, FileSystem, @{Name="Size(GB)";Expression={[math]::Round($_.Size / 1GB, 2)}}, @{Name="FreeSpace(GB)";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}} | Out-Host
}

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
    Get-Service -Name $services -ErrorAction SilentlyContinue | Select-Object DisplayName, Name, Status | Out-Host
}

<#
.SYNOPSIS
    Muestra el menú del módulo de análisis.
#>
function Show-AnalysisMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Análisis ---"
        Write-Host "1. Información del Sistema Operativo"
        Write-Host "2. Información del Hardware"
        Write-Host "3. Estado de Servicios Importantes"
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Get-OperatingSystemInfo }
            '2' { Get-HardwareInfo }
            '3' { Get-ImportantServicesStatus }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

#endregion

#region Limpieza

<#
.SYNOPSIS
    Elimina los archivos de las carpetas temporales del sistema.
.DESCRIPTION
    Limpia el contenido de %SystemRoot%\Temp y %TEMP%.
    Usa -ErrorAction SilentlyContinue para evitar errores si los archivos están en uso.
#>
function Clear-SystemTempFiles {
    Write-Log -Level INFO -Message "Limpiando archivos temporales del sistema..."
    $tempPaths = @("$env:SystemRoot\Temp", "$env:TEMP")
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log -Level INFO -Message "Archivos en $path eliminados."
        } else {
            Write-Log -Level WARNING -Message "El directorio $path no existe."
        }
    }
}

<#
.SYNOPSIS
    Elimina los archivos de la carpeta temporal del perfil de usuario.
.DESCRIPTION
    Limpia el contenido de %USERPROFILE%\AppData\Local\Temp.
#>
function Clear-UserTempFiles {
    Write-Log -Level INFO -Message "Limpiando archivos temporales del usuario..."
    $userTemp = "$env:USERPROFILE\AppData\Local\Temp"
    if (Test-Path $userTemp) {
        Remove-Item -Path "$userTemp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Level INFO -Message "Archivos en $userTemp eliminados."
    } else {
        Write-Log -Level WARNING -Message "El directorio $userTemp no existe."
    }
}

<#
.SYNOPSIS
    Vacia la papelera de reciclaje de todos los usuarios.
.DESCRIPTION
    Usa el cmdlet Clear-RecycleBin con el parámetro -Force para no pedir confirmación.
#>
function Invoke-ClearRecycleBin {
    Write-Log -Level INFO -Message "Vaciando la papelera de reciclaje..."
    Microsoft.PowerShell.Management\Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Log -Level INFO -Message "Papelera de reciclaje vaciada."
}

<#
.SYNOPSIS
    Elimina todos los puntos de restauración y las copias sombra (shadow copies).
.DESCRIPTION
    Ejecuta el comando vssadmin para eliminar todas las copias sombra, lo que incluye
    los puntos de restauración del sistema. Esta acción es irreversible y libera
    una cantidad significativa de espacio en disco.
#>
function Remove-SystemRestorePoints {
    Write-Log -Level WARNING -Message "Esta acción eliminará TODOS los puntos de restauración del sistema y las copias sombra."
    Write-Log -Level WARNING -Message "No podrás revertir el sistema a un estado anterior. Esta acción es IRREVERSIBLE."
    
    $confirmation = Read-Host "¿Estás SEGURO de que quieres continuar? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Eliminando copias sombra y puntos de restauración..."
        try {
            vssadmin.exe delete shadows /all /quiet
            Write-Log -Level INFO -Message "Se han eliminado correctamente."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error al eliminar las copias sombra: $_"
        }
    } else {
        Write-Log -Level INFO -Message "Operación cancelada por el usuario."
    }
}

<#
.SYNOPSIS
    Limpia la caché de descargas de Windows Update.
.DESCRIPTION
    Detiene el servicio de Windows Update, elimina los archivos de la caché de descargas
    y reinicia el servicio. Esto puede solucionar problemas con Windows Update y liberar espacio.
#>
function Clear-UpdateCache {
    Write-Log -Level INFO -Message "Limpiando la caché de Windows Update..."
    $path = "$env:SystemRoot\SoftwareDistribution\Download"

    Write-Log -Level INFO -Message "Deteniendo el servicio de Windows Update (wuauserv)..."
    Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue

    if (Test-Path -Path $path) {
        Write-Log -Level INFO -Message "Eliminando archivos de $path..."
        Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Log -Level INFO -Message "Archivos de la caché de Windows Update eliminados."
    } else {
        Write-Log -Level WARNING -Message "El directorio de la caché de Windows Update no se encontró en $path."
    }

    Write-Log -Level INFO -Message "Iniciando el servicio de Windows Update (wuauserv)..."
    Start-Service -Name wuauserv
    Write-Log -Level INFO -Message "Limpieza de caché de Windows Update completada."
}

<#
.SYNOPSIS
    Desactiva la hibernación del sistema para liberar espacio en disco.
.DESCRIPTION
    Ejecuta el comando powercfg para desactivar la hibernación. Esto elimina el archivo
    hiberfil.sys, que suele ocupar varios gigabytes. Como efecto secundario, también
    se deshabilita la característica de 'Inicio rápido' de Windows.
#>
function Disable-Hibernation {
    Write-Log -Level WARNING -Message "Esta acción desactivará la hibernación y el 'Inicio rápido' de Windows."
    $confirmation = Read-Host "¿Estás seguro de que quieres continuar? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Desactivando la hibernación..."
        try {
            powercfg.exe /hibernate off
            Write-Log -Level INFO -Message "Hibernación desactivada. El archivo hiberfil.sys ha sido eliminado."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error al desactivar la hibernación: $_"
        }
    } else {
        Write-Log -Level INFO -Message "Operación cancelada por el usuario."
    }
}

<#
.SYNOPSIS
    Limpia los componentes de Windows desactualizados en la carpeta WinSxS.

.DESCRIPTION
    Ejecuta la herramienta DISM (Deployment Image Servicing and Management) con los parámetros
    /Online /Cleanup-Image /StartComponentCleanup para eliminar versiones antiguas de componentes
    de Windows. Esta operación puede liberar una cantidad significativa de espacio en disco.
    Es un proceso que puede tardar varios minutos.

.NOTES
    Requiere privilegios de administrador para ejecutarse correctamente.
#>
function Clear-WinSxSComponent {
    Write-Log -Level INFO -Message "Iniciando limpieza de componentes de Windows (WinSxS)..."
    Write-Log -Level INFO -Message "Ejecutando 'Dism.exe /online /Cleanup-Image /StartComponentCleanup'. Este proceso puede tardar bastante."

    try {
        # Se redirige la salida para un futuro análisis si fuera necesario, pero el log principal informa del inicio/fin.
        Dism.exe /online /Cleanup-Image /StartComponentCleanup | Out-Null
        Write-Log -Level INFO -Message "La limpieza de componentes de WinSxS ha finalizado correctamente."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error durante la limpieza de WinSxS con DISM: $_"
    }
}

<#
.SYNOPSIS
    Limpia la caché de la aplicación de escritorio de Microsoft Teams.

.DESCRIPTION
    Localiza y elimina el contenido de las carpetas de caché de Microsoft Teams para el usuario actual.
    Esto puede solucionar problemas de la aplicación y liberar espacio en disco. La función se enfoca
    en la nueva versión de Teams ("Teams") y la clásica ("Teams Classic").

.NOTES
    Se recomienda cerrar Microsoft Teams antes de ejecutar esta función para asegurar que todos
    los archivos puedan ser eliminados.
#>
function Clear-TeamsCache {
    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de Microsoft Teams..."

    # Rutas de caché para la nueva versión de Teams y la clásica.
    # La nueva versión usa subcarpetas dentro de %LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe\
    $newTeamsPath = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe"
    # La versión clásica usa %APPDATA%\Microsoft\Teams
    $classicTeamsPath = "$env:APPDATA\Microsoft\Teams"

    $cachePaths = @() 
    if (Test-Path -Path $newTeamsPath) {
        $cachePaths += Get-ChildItem -Path $newTeamsPath -Directory -Recurse | Where-Object { $_.Name -in @('Cache', 'Code Cache', 'GPUCache') } | Select-Object -ExpandProperty FullName
    }
    if (Test-Path -Path $classicTeamsPath) {
        $cachePaths += Get-ChildItem -Path $classicTeamsPath -Directory -Recurse | Where-Object { $_.Name -in @('Cache', 'Code Cache', 'GPUCache', 'Application Cache') } | Select-Object -ExpandProperty FullName
    }

    if ($cachePaths.Count -eq 0) {
        Write-Log -Level INFO -Message "No se encontraron carpetas de caché de Microsoft Teams para el usuario actual."
        return
    }

    foreach ($path in $cachePaths) {
        Write-Log -Level INFO -Message "Limpiando carpeta: $path"
        try {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction Stop
            Write-Log -Level INFO -Message "Contenido de $path eliminado correctamente."
        }
        catch {
            Write-Log -Level WARNING -Message "No se pudo eliminar todo el contenido de $path. Es posible que Teams siga en ejecución. Detalles: $_"
        }
    }

    Write-Log -Level INFO -Message "Limpieza de la caché de Microsoft Teams finalizada."
}

<#
.SYNOPSIS
    Muestra el menú del módulo de limpieza.
#>
function Show-CleanupMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Limpieza ---"
        Write-Host "1. Limpiar archivos temporales del sistema"
        Write-Host "2. Limpiar archivos temporales del usuario"
        Write-Host "3. Vaciar la papelera de reciclaje"
        Write-Host "4. Eliminar puntos de restauración y copias sombra"
        Write-Host "5. Limpiar caché de Windows Update"
        Write-Host "6. Desactivar hibernación (libera mucho espacio)"
        Write-Host "7. Limpiar componentes de Windows (WinSxS)"
        Write-Host "8. Limpiar caché de Microsoft Teams"
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Clear-SystemTempFiles }
            '2' { Clear-UserTempFiles }
            '3' { Invoke-ClearRecycleBin }
            '4' { Remove-SystemRestorePoints }
            '5' { Clear-UpdateCache }
            '6' { Disable-Hibernation }
            '7' { Clear-WinSxSComponent }
            '8' { Clear-TeamsCache }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

#endregion

#region Optimización

<#
.SYNOPSIS
    Ajusta la configuración de efectos visuales de Windows para un mejor rendimiento.
.DESCRIPTION
    Modifica la clave de registro 'VisualFxSetting' a '2' (Mejor rendimiento)
    y reactiva el suavizado de fuentes para mantener la legibilidad del texto.
#>
function Set-PerformanceVisualEffects {
    Write-Log -Level INFO -Message "Ajustando efectos visuales para mejor rendimiento..."
    # El valor '2' corresponde a "Ajustar para obtener el mejor rendimiento".
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFxSetting" -Value 2
    # Se reactiva el suavizado de fuentes (ClearType) para no sacrificar la legibilidad.
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 2
    Write-Log -Level INFO -Message "Efectos visuales ajustados. Se recomienda reiniciar el explorador o la sesión."
}

<#
.SYNOPSIS
    Detiene y deshabilita una lista de servicios no esenciales definida en la configuración.
.DESCRIPTION
    Carga la lista de servicios desde el archivo config.json. Recorre la lista y, si existen,
    los detiene y establece su tipo de inicio en 'Deshabilitado'.
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

<#
.SYNOPSIS
    Establece el plan de energía de Windows en 'Alto rendimiento'.
.DESCRIPTION
    Busca el GUID del plan de energía 'Alto rendimiento' usando powercfg.exe
    y lo establece como el plan activo.
#>
function Set-HighPerformancePowerPlan {
    Write-Log -Level INFO -Message "Aplicando plan de energía de alto rendimiento..."
    # Busca la línea que contiene "Alto rendimiento" y extrae el GUID.
    $highPerformance = powercfg /list | Where-Object { $_ -match "Alto rendimiento" } | ForEach-Object { ($_.Split(" "))[3] }
    if ($highPerformance) {
        powercfg /setactive $highPerformance
        Write-Log -Level INFO -Message "Plan de energía de alto rendimiento activado."
    } else {
        Write-Log -Level WARNING -Message "No se encontró el plan de energía de alto rendimiento."
    }
}

<#
.SYNOPSIS
    Muestra el menú del módulo de optimización.
#>
function Show-OptimizationMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Optimización ---"
        Write-Host "1. Ajustar efectos visuales para mejor rendimiento"
        Write-Host "2. Gestionar servicios no esenciales"
        Write-Host "3. Aplicar plan de energía de alto rendimiento"
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Set-PerformanceVisualEffects }
            '2' { Manage-NonEssentialServices }
            '3' { Set-HighPerformancePowerPlan }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

#endregion

#region Mantenimiento

<#
.SYNOPSIS
    Crea un punto de restauración del sistema.
.DESCRIPTION
    Utiliza el cmdlet Checkpoint-Computer para crear un punto de restauración
    con una descripción que incluye la fecha y hora actuales.
#>
function New-SystemRestorePoint {
    Write-Log -Level INFO -Message "Creando punto de restauración del sistema..."
    $description = "OptiTech Restore Point - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Checkpoint-Computer -Description $description
    Write-Log -Level INFO -Message "Punto de restauración '$description' creado."
}

<#
.SYNOPSIS
    Ejecuta el Comprobador de archivos de sistema (SFC).
.DESCRIPTION
    Invoca a sfc.exe con el argumento /scannow para verificar la integridad
    de los archivos de sistema y repararlos si es necesario.
#>
function Run-SFCScan {
    Write-Log -Level INFO -Message "Ejecutando 'sfc /scannow'... Este proceso puede tardar varios minutos."
    sfc.exe /scannow
    Write-Log -Level INFO -Message "'sfc /scannow' completado."
}

<#
.SYNOPSIS
    Ejecuta la herramienta DISM para reparar la imagen de Windows.
.DESCRIPTION
    Invoca a dism.exe para realizar una comprobación de estado y reparación
    de la imagen del sistema operativo.
#>
function Run-DISMScan {
    Write-Log -Level INFO -Message "Ejecutando 'DISM /Online /Cleanup-Image /RestoreHealth'... Este proceso puede tardar varios minutos."
    dism.exe /online /cleanup-image /restorehealth
    Write-Log -Level INFO -Message "'DISM /Online /Cleanup-Image /RestoreHealth' completado."
}

<#
.SYNOPSIS
    Crea una copia de seguridad de las ramas principales del Registro de Windows.
.DESCRIPTION
    Crea un directorio 'RegistryBackup' en la ruta del script si no existe.
    Luego, exporta las ramas HKEY_LOCAL_MACHINE y HKEY_CURRENT_USER a archivos .reg
    separados, usando la fecha y hora actual en el nombre del archivo.
#>
function New-RegistryBackup {
    Write-Log -Level INFO -Message "Iniciando copia de seguridad del Registro..."
    $backupDir = "$PSScriptRoot\RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory | Out-Null
        Write-Log -Level INFO -Message "Directorio de copias de seguridad creado en $backupDir"
    }

    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $hklmPath = "$backupDir\HKLM_backup_$timestamp.reg"
    $hkcuPath = "$backupDir\HKCU_backup_$timestamp.reg"

    try {
        Write-Log -Level INFO -Message "Exportando HKEY_LOCAL_MACHINE a $hklmPath..."
        reg.exe export HKLM "$hklmPath" /y
        Write-Log -Level INFO -Message "Exportando HKEY_CURRENT_USER a $hkcuPath..."
        reg.exe export HKCU "$hkcuPath" /y
        Write-Log -Level INFO -Message "Copia de seguridad del Registro completada con éxito."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error durante la copia de seguridad del Registro: $_"
    }
}

<#
.SYNOPSIS
    Restaura el Registro de Windows desde una copia de seguridad.
.DESCRIPTION
    Muestra una lista de los archivos de copia de seguridad .reg disponibles. El usuario
    debe seleccionar un archivo para importarlo. Esta es una operación de ALTO RIESGO
    que puede causar inestabilidad en el sistema si se usa un archivo corrupto o incorrecto.
    Requiere una doble confirmación por parte del usuario.
#>
function Restore-RegistryBackup {
    Write-Log -Level WARNING -Message "--- ¡OPERACIÓN DE ALTO RIESGO! ---"
    Write-Log -Level WARNING -Message "Restaurar el Registro puede causar daños graves e irreversibles en el sistema si algo sale mal."
    
    $backupDir = "$PSScriptRoot\RegistryBackup"
    if (-not (Test-Path -Path $backupDir)) {
        Write-Log -Level ERROR -Message "El directorio de copias de seguridad '$backupDir' no existe. No hay nada que restaurar."
        return
    }

    $backups = Get-ChildItem -Path $backupDir -Filter "*.reg"
    if ($backups.Count -eq 0) {
        Write-Log -Level WARNING -Message "No se encontraron archivos de copia de seguridad (.reg) en $backupDir."
        return
    }

    Write-Log -Level INFO -Message "Copias de seguridad disponibles:"
    for ($i = 0; $i -lt $backups.Count; $i++) {
        Write-Host ("{0}: {1}" -f ($i + 1), $backups[$i].Name)
    }

    $choice = Read-Host "Selecciona el NÚMERO del archivo que quieres restaurar (o presiona Enter para cancelar)"
    if ([string]::IsNullOrWhiteSpace($choice) -or $choice -notmatch '^\d+$') {
        Write-Log -Level INFO -Message "Restauración cancelada."
        return
    }

    $index = [int]$choice - 1
    if ($index -lt 0 -or $index -ge $backups.Count) {
        Write-Log -Level ERROR -Message "Selección no válida."
        return
    }

    $fileToRestore = $backups[$index]
    Write-Log -Level WARNING -Message "Has seleccionado restaurar desde el archivo '$($fileToRestore.Name)'."
    $confirmation = Read-Host "Para confirmar esta acción PELIGROSA, escribe el nombre completo del archivo de nuevo."

    if ($confirmation -eq $fileToRestore.Name) {
        Write-Log -Level INFO -Message "Iniciando la restauración del Registro desde '$($fileToRestore.FullName)'..."
        try {
            reg.exe import "$($fileToRestore.FullName)"
            Write-Log -Level INFO -Message "Restauración del Registro completada. Se recomienda reiniciar el equipo."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error durante la restauración: $_"
        }
    } else {
        Write-Log -Level INFO -Message "La confirmación no coincide. Operación de restauración cancelada."
    }
}

<#
.SYNOPSIS
    Ejecuta una comprobación del disco del sistema (chkdsk).
.DESCRIPTION
    Invoca a chkdsk.exe en la unidad C: con los parámetros /f /r para corregir errores y recuperar datos.
    Si la unidad está en uso, programará el análisis para el próximo reinicio del sistema.
#>
function Start-ChkdskScan {
    Write-Log -Level INFO -Message "Iniciando comprobación de disco (chkdsk C: /f /r)..."
    Write-Log -Level WARNING -Message "Este proceso programará un análisis de la unidad C: en el próximo reinicio."
    
    $confirmation = Read-Host "¿Quieres programar un chkdsk en la unidad C: para el próximo reinicio? Escribe 'SI' para confirmar."

    if ($confirmation -eq 'SI') {
        Write-Log -Level INFO -Message "Programando chkdsk..."
        try {
            # Forzamos la respuesta 'S' (Sí) a la pregunta de chkdsk
            echo 'S' | chkdsk C: /f /r
            Write-Log -Level INFO -Message "Se ha programado un análisis de disco para el próximo reinicio."
        }
        catch {
            Write-Log -Level ERROR -Message "Ocurrió un error al programar chkdsk: $_"
        }
    } else {
        Write-Log -Level INFO -Message "Operación cancelada por el usuario."
    }
}

<#
.SYNOPSIS
    Muestra el menú del módulo de mantenimiento.
#>
function Show-MaintenanceMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Mantenimiento y Copias de Seguridad ---"
        Write-Host "1. Crear punto de restauración del sistema"
        Write-Host "2. Ejecutar 'sfc /scannow'"
        Write-Host "3. Ejecutar 'DISM /Online /Cleanup-Image /RestoreHealth'"
        Write-Host "4. Crear copia de seguridad del Registro"
        Write-Host "5. Restaurar copia de seguridad del Registro (Alto Riesgo)"
        Write-Host "6. Programar comprobación de disco (chkdsk)"
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { New-SystemRestorePoint }
            '2' { Run-SFCScan }
            '3' { Run-DISMScan }
            '4' { New-RegistryBackup }
            '5' { Restore-RegistryBackup }
            '6' { Start-ChkdskScan }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

#endregion

#region Red

<#
.SYNOPSIS
    Limpia la caché de resolución de DNS.
.DESCRIPTION
    Ejecuta ipconfig /flushdns para borrar la caché de DNS, lo que puede
    solucionar problemas de conectividad o de acceso a sitios web.
#>
function Flush-DnsCache {
    Write-Log -Level INFO -Message "Limpiando la caché de DNS (ipconfig /flushdns)..."
    try {
        ipconfig /flushdns
        Write-Log -Level INFO -Message "Caché de DNS limpiada correctamente."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error al limpiar la caché de DNS: $_"
    }
}

<#
.SYNOPSIS
    Renueva la concesión de la dirección IP.
.DESCRIPTION
    Ejecuta ipconfig /renew para solicitar una nueva dirección IP al servidor DHCP.
    Útil para solucionar problemas de conectividad de red.
#>
function Renew-IpAddress {
    Write-Log -Level INFO -Message "Renovando la dirección IP (ipconfig /renew)..."
    try {
        ipconfig /renew
        Write-Log -Level INFO -Message "Dirección IP renovada correctamente."
    }
    catch {
        Write-Log -Level ERROR -Message "Ocurrió un error al renovar la dirección IP: $_"
    }
}

<#
.SYNOPSIS
    Muestra el menú del módulo de Red y Conectividad.
#>
function Show-NetworkMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Red y Conectividad ---"
        Write-Host "1. Limpiar la caché de DNS (flushdns)"
        Write-Host "2. Renovar la dirección IP (renew)"
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Flush-DnsCache }
            '2' { Renew-IpAddress }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

#endregion


function Show-NetworkMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Red y Conectividad ---"
        Write-Host "1. Limpiar la caché de DNS (flushdns)"
        Write-Host "2. Renovar la dirección IP (renew)"
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione una opción"

        switch ($choice) {
            '1' { Flush-DnsCache }
            '2' { Renew-IpAddress }
            'V' { return }
            default { Write-Warning "Opción no válida." }
        }
        Read-Host "Presione Enter para continuar..."
    }
}

#endregion

<#
.SYNOPSIS
    Genera un resumen de las operaciones realizadas por OptiTech.

.DESCRIPTION
    Esta función toma una colección de objetos de log (generados por Write-Log)
    y crea un resumen ejecutivo de las acciones, el estado y los resultados clave.
    El resumen se muestra en la consola.

.PARAMETER LogEntries
    Colección de objetos PSCustomObject devueltos por la función Write-Log,
    que representan todas las entradas de log de la ejecución actual.
#>
function Write-OptiTechSummary {
    param(
        [Parameter(Mandatory=$true)]
        [PSCustomObject[]]$LogEntries
    )

    $summary = New-Object System.Text.StringBuilder
    $summary.AppendLine("\n--- Resumen de Operaciones OptiTech ---")
    $summary.AppendLine("Fecha y Hora de Ejecución: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    $summary.AppendLine("----------------------------------------")

    # Contar acciones por nivel
    $infoCount = ($LogEntries | Where-Object { $_.Level -eq 'INFO' }).Count
    $warningCount = ($LogEntries | Where-Object { $_.Level -eq 'WARNING' }).Count
    $errorCount = ($LogEntries | Where-Object { $_.Level -eq 'ERROR' }).Count

    $summary.AppendLine("Acciones INFO: $infoCount")
    $summary.AppendLine("Advertencias: $warningCount")
    $summary.AppendLine("Errores: $errorCount")
    $summary.AppendLine("")

    $summary.AppendLine("Detalles de las acciones (últimos 10 mensajes INFO/WARNING/ERROR):")
    $LogEntries | Select-Object -Last 10 | ForEach-Object {
        $summary.AppendLine("  [$($_.Timestamp)] [$($_.Level)] - $($_.Message)")
    }

    $summary.AppendLine("----------------------------------------")
    $summary.AppendLine("Log completo disponible en: $script:LogFilePath")

    Write-Host $summary.ToString() -ForegroundColor White
}

<#
.SYNOPSIS
    Permite al usuario seleccionar y ejecutar un perfil de optimización automatizado.
.DESCRIPTION
    Carga los perfiles definidos en config.json, los presenta al usuario y ejecuta
    las tareas asociadas al perfil seleccionado de forma secuencial.
#>
function Invoke-AutomatedProfile {
    $script:CurrentLogEntries = @() # Variable para recopilar logs de esta ejecución automatizada

    Write-Log -Level INFO -Message "Iniciando ejecución de perfil automatizado."
    $config = Get-OptiTechConfig
    if (-not $config -or -not $config.Profiles) {
        $script:CurrentLogEntries += (Write-Log -Level ERROR -Message "No se encontraron perfiles en config.json. Abortando.")
        return
    }

    $profileNames = $config.Profiles.PSObject.Properties.Name
    if ($profileNames.Count -eq 0) {
        $script:CurrentLogEntries += (Write-Log -Level WARNING -Message "No hay perfiles definidos en config.json. Abortando.")
        return
    }

    while ($true) {
        Clear-Host
        Write-Host "--- Seleccionar Perfil Automatizado ---"
        for ($i = 0; $i -lt $profileNames.Count; $i++) {
            Write-Host ("{0}. {1}" -f ($i + 1), $profileNames[$i])
        }
        Write-Host "V. Volver al menú principal"

        $choice = Read-Host "Seleccione un perfil para ejecutar"

        if ($choice -eq 'V') { return }

        if ($choice -match '^\d+$' -and ([int]$choice -gt 0) -and ([int]$choice -le $profileNames.Count)) {
            $selectedProfileName = $profileNames[[int]$choice - 1]
            $script:CurrentLogEntries += (Write-Log -Level INFO -Message "Perfil seleccionado: $selectedProfileName. Iniciando tareas...")
            
            $tasksToExecute = $config.Profiles.$selectedProfileName
            foreach ($taskName in $tasksToExecute) {
                $script:CurrentLogEntries += (Write-Log -Level INFO -Message "Ejecutando tarea: $taskName")
                if (Get-Command -Name $taskName -CommandType Function -ErrorAction SilentlyContinue) {
                    try {
                        # Ejecutar la función y capturar su salida si devuelve algo (aunque Write-Log ya lo hace)
                        & $taskName
                        $script:CurrentLogEntries += (Write-Log -Level INFO -Message "Tarea '$taskName' completada.")
                    }
                    catch {
                        $script:CurrentLogEntries += (Write-Log -Level ERROR -Message "Error al ejecutar la tarea '$taskName': $($_.Exception.Message)")
                    }
                } else {
                    $script:CurrentLogEntries += (Write-Log -Level WARNING -Message "La tarea '$taskName' no es una función válida. Omitiendo.")
                }
            }
            $script:CurrentLogEntries += (Write-Log -Level INFO -Message "Ejecución del perfil '$selectedProfileName' finalizada.")
            Write-OptiTechSummary -LogEntries $script:CurrentLogEntries
            $script:CurrentLogEntries = @() # Limpiar para la próxima ejecución
            Read-Host "Presione Enter para continuar..."
            return
        } else {
            Write-Warning "Opción no válida. Por favor, intente de nuevo."
            Read-Host "Presione Enter para continuar..."
        }
    }
}

# --- INICIALIZACIÓN Y VERIFICACIÓN ---

# Se asegura de que el sistema de logging esté listo.
Initialize-Logging
# Se asegura de que el script se ejecute con los privilegios necesarios.
Invoke-AdminElevation

# --- BUCLE PRINCIPAL DEL MENÚ ---

while ($true) {
    Clear-Host
    Write-Host "========================================="
    Write-Host "   OptiTech System Optimizer"
    Write-Host "========================================="
    Write-Host
    Write-Host "1. Análisis del Sistema"
    Write-Host "2. Limpieza del Sistema"
    Write-Host "3. Optimización del Sistema"
    Write-Host "4. Mantenimiento y Copias de Seguridad"
    Write-Host "5. Red y Conectividad"
    Write-Host
    Write-Host "A. Ejecutar Perfil Automatizado"
    Write-Host
    Write-Host "S. Salir"
    Write-Host

    $opcion = Read-Host "Seleccione una opción"

    switch ($opcion) {
        '1' { Show-AnalysisMenu }
        '2' { Show-CleanupMenu }
        '3' { Show-OptimizationMenu }
        '4' { Show-MaintenanceMenu }
        '5' { Show-NetworkMenu }
        'A' { Invoke-AutomatedProfile }
        'S' {
            Write-Host "Saliendo de OptiTech System Optimizer."
            break
        }
        default {
            Write-Warning "Opción no válida. Por favor, intente de nuevo."
        }
    }
    Read-Host "Presione Enter para continuar..."
}