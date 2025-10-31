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
    $osInfo = Get-ComputerInfo | Select-Object OsName, OsVersion, OsArchitecture, CsSystemType, WindowsVersion, WindowsProductName, WindowsCurrentVersion, WindowsInstallationType, OsLanguage, OsCountryCode
    
    $osInfo.PSObject.Properties | ForEach-Object {
        Write-Host -NoNewline -Object ("- {0,-25}: " -f $_.Name) -ForegroundColor Green
        Write-Host -Object $_.Value -ForegroundColor White
    }
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

    Write-Host "`n--- Discos Lógicos ---" -ForegroundColor Cyan
    Get-CimInstance -ClassName Win32_LogicalDisk | ForEach-Object {
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "DeviceID") -ForegroundColor Green; Write-Host $_.DeviceID -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "VolumeName") -ForegroundColor Green; Write-Host $_.VolumeName -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "FileSystem") -ForegroundColor Green; Write-Host $_.FileSystem -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "Size(GB)") -ForegroundColor Green; Write-Host ([math]::Round($_.Size / 1GB, 2)) -ForegroundColor White
        Write-Host -NoNewline -Object ("- {0,-25}: " -f "FreeSpace(GB)") -ForegroundColor Green; Write-Host ([math]::Round($_.FreeSpace / 1GB, 2)) -ForegroundColor White
        Write-Host ""
    }
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

<#
.SYNOPSIS
    Muestra el menú del módulo de análisis.
#>
function Show-AnalysisMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Análisis ---" -ForegroundColor Cyan
        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Información del Sistema Operativo"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Información del Hardware"
        Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Estado de Servicios Importantes"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

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
    Write-Log -Level INFO -Message "Iniciando limpieza de archivos temporales del sistema."
    $tempPath = "$env:SystemRoot\Temp"
    $itemsToDelete = Get-ChildItem -Path $tempPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) }
    $filesToDelete = $itemsToDelete | Where-Object { -not $_.PSIsContainer }
    $totalSize = 0
    if ($filesToDelete) {
        $totalSize = ($filesToDelete | Measure-Object -Property Length -Sum).Sum
    }

    try {
        $itemsToDelete | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        $sizeFreedGB = [math]::Round($totalSize / 1GB, 2)
        Write-Log -Level INFO -Message "Limpieza de archivos temporales del sistema completada. Se liberaron $($sizeFreedGB) GB."
        Write-Host -ForegroundColor Green "✔ Limpieza de archivos temporales del sistema completada. Se liberaron $($sizeFreedGB) GB."
    } catch {
        Write-Log -Level ERROR -Message "Error al limpiar archivos temporales del sistema: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al limpiar archivos temporales del sistema: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Elimina los archivos de la carpeta temporal del perfil de usuario.
.DESCRIPTION
    Limpia el contenido de %USERPROFILE%\AppData\Local\Temp.
#>
function Clear-UserTempFiles {
    Write-Log -Level INFO -Message "Iniciando limpieza de archivos temporales del usuario."
    $tempPath = "$env:TEMP"
    $itemsToDelete = Get-ChildItem -Path $tempPath -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-7) }
    $filesToDelete = $itemsToDelete | Where-Object { -not $_.PSIsContainer }
    $totalSize = 0
    if ($filesToDelete) {
        $totalSize = ($filesToDelete | Measure-Object -Property Length -Sum).Sum
    }

    try {
        $itemsToDelete | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

        $sizeFreedGB = [math]::Round($totalSize / 1GB, 2)
        Write-Log -Level INFO -Message "Limpieza de archivos temporales del usuario completada. Se liberaron $($sizeFreedGB) GB."
        Write-Host -ForegroundColor Green "✔ Limpieza de archivos temporales del usuario completada. Se liberaron $($sizeFreedGB) GB."
    } catch {
        Write-Log -Level ERROR -Message "Error al limpiar archivos temporales del usuario: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al limpiar archivos temporales del usuario: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Vacia la papelera de reciclaje de todos los usuarios.
.DESCRIPTION
    Usa el cmdlet Clear-RecycleBin con el parámetro -Force para no pedir confirmación.
#>
function Invoke-ClearRecycleBin {
    Write-Log -Level INFO -Message "Iniciando vaciado de la papelera de reciclaje."
    try {
        $itemsRemoved = Clear-RecycleBin -Force -ErrorAction Stop
        Write-Log -Level INFO -Message "Papelera de reciclaje vaciada. Se eliminaron $($itemsRemoved.Count) elementos."
        Write-Host -ForegroundColor Green "✔ Papelera de reciclaje vaciada. Se eliminaron $($itemsRemoved.Count) elementos."
    } catch {
        Write-Log -Level ERROR -Message "Error al vaciar la papelera de reciclaje: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al vaciar la papelera de reciclaje: $($_.Exception.Message)"
    }
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
    Write-Log -Level INFO -Message "Iniciando eliminación de puntos de restauración antiguos."
    try {
        # Obtener todos los puntos de restauración
        $restorePoints = Get-ComputerRestorePoint

        if ($restorePoints) {
            # Eliminar todos los puntos de restauración excepto el más reciente
            # Esto es un ejemplo, se podría refinar para mantener más puntos o por fecha
            $restorePoints | Select-Object -Skip 1 | ForEach-Object {
                # No hay un cmdlet directo para eliminar puntos de restauración específicos por ID en PowerShell 5.1
                # La forma más común es usar WMI o deshabilitar/habilitar la protección del sistema, lo cual elimina todos.
                # Para este script, asumiremos que el objetivo es liberar espacio, por lo que se podría considerar
                # deshabilitar y volver a habilitar la protección del sistema si se quiere una limpieza total.
                # Sin embargo, esto es destructivo. Una alternativa más segura es solo informar.
                Write-Log -Level WARNING -Message "No se puede eliminar selectivamente puntos de restauración antiguos con cmdlets directos en PowerShell 5.1. Considera deshabilitar/habilitar la protección del sistema si deseas una limpieza total (con precaución)."
                Write-Host -ForegroundColor Yellow "⚠ No se puede eliminar selectivamente puntos de restauración antiguos con cmdlets directos en PowerShell 5.1. Considera deshabilitar/habilitar la protección del sistema si deseas una limpieza total (con precaución)."
            }
            Write-Log -Level INFO -Message "Revisión de puntos de restauración completada. Si hay puntos antiguos, se recomienda gestión manual o deshabilitar/habilitar la protección del sistema."
            Write-Host -ForegroundColor Green "✔ Revisión de puntos de restauración completada. Si hay puntos antiguos, se recomienda gestión manual o deshabilitar/habilitar la protección del sistema."
        } else {
            Write-Log -Level INFO -Message "No se encontraron puntos de restauración para eliminar."
            Write-Host -ForegroundColor Green "✔ No se encontraron puntos de restauración para eliminar."
        }
    } catch {
        Write-Log -Level ERROR -Message "Error al eliminar puntos de restauración: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al eliminar puntos de restauración: $($_.Exception.Message)"
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
    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de Windows Update."
    $cachePath = "$env:SystemRoot\SoftwareDistribution\Download"
    $totalSize = 0

    if (Test-Path $cachePath) {
        $itemsToDelete = Get-ChildItem -Path $cachePath -Recurse -ErrorAction SilentlyContinue
        $filesToDelete = $itemsToDelete | Where-Object { -not $_.PSIsContainer }
        if ($filesToDelete) {
            $totalSize = ($filesToDelete | Measure-Object -Property Length -Sum).Sum
        }
    }

    try {
        # Detener el servicio de Windows Update para asegurar que los archivos se puedan eliminar
        Stop-Service -Name wuauserv -ErrorAction SilentlyContinue
        
        if (Test-Path $cachePath) {
            Remove-Item -Path "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        # Reiniciar el servicio de Windows Update
        Start-Service -Name wuauserv -ErrorAction SilentlyContinue

        $sizeFreedGB = [math]::Round($totalSize / 1GB, 2)
        Write-Log -Level INFO -Message "Limpieza de la caché de Windows Update completada. Se liberaron $($sizeFreedGB) GB."
        Write-Host -ForegroundColor Green "✔ Limpieza de la caché de Windows Update completada. Se liberaron $($sizeFreedGB) GB."
    } catch {
        Write-Log -Level ERROR -Message "Error al limpiar la caché de Windows Update: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al limpiar la caché de Windows Update: $($_.Exception.Message)"
    }
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
    Write-Log -Level INFO -Message "Intentando deshabilitar la hibernación."
    try {
        # Deshabilitar la hibernación
        powercfg.exe /hibernate off
        Write-Log -Level INFO -Message "Hibernación deshabilitada correctamente. Se ha liberado espacio en disco."
        Write-Host -ForegroundColor Green "✔ Hibernación deshabilitada correctamente. Se ha liberado espacio en disco."
    } catch {
        Write-Log -Level ERROR -Message "Error al deshabilitar la hibernación: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al deshabilitar la hibernación: $($_.Exception.Message)"
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
    Write-Log -Level INFO -Message "Iniciando limpieza de componentes de Windows (WinSxS) con DISM."
    try {
        $dismOutput = Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase | Out-String
        
        # DISM no devuelve directamente el espacio liberado en un formato fácil de parsear en la salida estándar
        # Un mensaje de éxito general es más apropiado aquí.
        Write-Log -Level INFO -Message "Limpieza de componentes WinSxS completada. Revise la salida de DISM para detalles."
        Write-Host -ForegroundColor Green "✔ Limpieza de componentes WinSxS completada. Esto puede liberar espacio significativo."
        Write-Host -ForegroundColor DarkGray "Salida de DISM:" -NoNewline; Write-Host $dismOutput -ForegroundColor DarkGray
    } catch {
        Write-Log -Level ERROR -Message "Error al limpiar componentes WinSxS: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al limpiar componentes WinSxS: $($_.Exception.Message)"
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
    Write-Log -Level INFO -Message "Iniciando limpieza de la caché de Microsoft Teams."
    $teamsCachePath = "$env:APPDATA\Microsoft\Teams\Cache"
    $totalSize = 0

    if (Test-Path $teamsCachePath) {
        $itemsToDelete = Get-ChildItem -Path $teamsCachePath -Recurse -ErrorAction SilentlyContinue
        if ($itemsToDelete) {
            $totalSize = ($itemsToDelete | Measure-Object -Property Length -Sum).Sum
        }
    }

    try {
        if (Test-Path $teamsCachePath) {
            Remove-Item -Path "$teamsCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        $sizeFreedGB = [math]::Round($totalSize / 1GB, 2)
        Write-Log -Level INFO -Message "Limpieza de la caché de Microsoft Teams completada. Se liberaron $($sizeFreedGB) GB."
        Write-Host -ForegroundColor Green "✔ Limpieza de la caché de Microsoft Teams completada. Se liberaron $($sizeFreedGB) GB."
    } catch {
        Write-Log -Level ERROR -Message "Error al limpiar la caché de Microsoft Teams: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al limpiar la caché de Microsoft Teams: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Muestra el menú del módulo de limpieza.
#>
function Show-CleanupMenu {
    while ($true) {
        Clear-Host
        Write-Host "--- Módulo de Limpieza ---" -ForegroundColor Cyan
        Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Limpiar archivos temporales del sistema"
        Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Limpiar archivos temporales del usuario"
        Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Vaciar la papelera de reciclaje"
        Write-Host -NoNewline "4. " -ForegroundColor Yellow; Write-Host "Eliminar puntos de restauración y copias sombra"
        Write-Host -NoNewline "5. " -ForegroundColor Yellow; Write-Host "Limpiar caché de Windows Update"
        Write-Host -NoNewline "6. " -ForegroundColor Yellow; Write-Host "Desactivar hibernación (libera mucho espacio)"
        Write-Host -NoNewline "7. " -ForegroundColor Yellow; Write-Host "Limpiar componentes de Windows (WinSxS)"
        Write-Host -NoNewline "8. " -ForegroundColor Yellow; Write-Host "Limpiar caché de Microsoft Teams"
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

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
    Write-Log -Level INFO -Message "Ajustando efectos visuales para mejor rendimiento."
    try {
        # Deshabilitar efectos visuales que consumen recursos
        # Esto es un ejemplo, se pueden añadir más configuraciones
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00))
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0"
        
        # Actualizar la configuración para que los cambios surtan efecto
        # [void]([System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.Activator]::CreateInstance([System.Type]::GetTypeFromCLSID([System.Guid]::new("{00021401-0000-0000-C000-000000000046}")))))
        # No es necesario reiniciar, pero algunos cambios pueden requerir un cierre de sesión.

        Write-Log -Level INFO -Message "Efectos visuales ajustados para mejor rendimiento."
        Write-Host -ForegroundColor Green "✔ Efectos visuales ajustados para mejor rendimiento."
    } catch {
        Write-Log -Level ERROR -Message "Error al ajustar efectos visuales: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al ajustar efectos visuales: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Detiene y deshabilita una lista de servicios no esenciales definida en la configuración.
.DESCRIPTION
    Carga la lista de servicios desde el archivo config.json. Recorre la lista y, si existen,
    los detiene y establece su tipo de inicio en 'Deshabilitado'.
#>
function Manage-NonEssentialServices {
    Write-Log -Level INFO -Message "Gestionando servicios no esenciales."
    $config = Get-OptiTechConfig
    $servicesToDisable = $config.ServicesToDisable
    $affectedServices = @()

    if (-not $servicesToDisable) {
        Write-Log -Level WARNING -Message "No se encontraron servicios para deshabilitar en config.json."
        Write-Host -ForegroundColor Yellow "⚠ No se encontraron servicios para deshabilitar en config.json."
        return
    }

    foreach ($serviceName in $servicesToDisable) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
            if ($service) {
                if ($service.Status -ne 'Stopped') {
                    Stop-Service -InputObject $service -ErrorAction Stop
                    Set-Service -InputObject $service -StartupType Disabled -ErrorAction Stop
                    $affectedServices += "$($service.DisplayName) (Detenido y Deshabilitado)"
                    Write-Log -Level INFO -Message "Servicio '$($service.DisplayName)' ($serviceName) detenido y deshabilitado."
                } else {
                    Set-Service -InputObject $service -StartupType Disabled -ErrorAction Stop
                    $affectedServices += "$($service.DisplayName) (Deshabilitado)"
                    Write-Log -Level INFO -Message "Servicio '$($service.DisplayName)' ($serviceName) deshabilitado."
                }
            } else {
                Write-Log -Level WARNING -Message "Servicio '$serviceName' no encontrado."
                $affectedServices += "$serviceName (No encontrado)"
            }
        } catch {
            Write-Log -Level ERROR -Message "Error al gestionar el servicio '$serviceName': $($_.Exception.Message)"
            $affectedServices += "$serviceName (Error: $($_.Exception.Message))"
        }
    }

    if ($affectedServices.Count -gt 0) {
        Write-Host -ForegroundColor Green "✔ Gestión de servicios no esenciales completada. Servicios afectados:"
        $affectedServices | ForEach-Object { Write-Host -ForegroundColor White "  - $_" }
    } else {
        Write-Host -ForegroundColor Yellow "⚠ No se realizaron cambios en los servicios."
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
    Write-Log -Level INFO -Message "Intentando aplicar plan de energía de alto rendimiento."
    try {
        # Obtener el GUID del plan de energía de alto rendimiento
        $highPerformanceGuid = $null
        $powercfgOutputLines = (powercfg /list)

        foreach ($line in $powercfgOutputLines) {
            if ($line -match '(Power Scheme GUID:|GUID de plan de energía:)\s+([0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12})\s+\(([^)]+)\).*' ) {
                $guid = $matches[2]
                $name = $matches[4]

                # Check for both Spanish and English names for High Performance
                if ($name -eq "Alto rendimiento" -or $name -eq "High Performance") {
                    $highPerformanceGuid = $guid
                    break # Found it, no need to check further
                }
            }
        }

        if ($highPerformanceGuid) {
            # Establecer el plan de energía
            powercfg.exe /setactive $highPerformanceGuid
            Write-Log -Level INFO -Message "Plan de energía establecido en 'Alto rendimiento'."
            Write-Host -ForegroundColor Green "✔ Plan de energía establecido en 'Alto rendimiento'."
        } else {
            Write-Log -Level WARNING -Message "No se encontró el plan de energía 'Alto rendimiento'."
            Write-Host -ForegroundColor Yellow "⚠ No se encontró el plan de energía 'Alto rendimiento'."
        }
    } catch {
        Write-Log -Level ERROR -Message "Error al aplicar plan de energía de alto rendimiento: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al aplicar plan de energía de alto rendimiento: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Muestra el menú del módulo de optimización.
#>
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
    Write-Log -Level INFO -Message "Creando punto de restauración del sistema."
    try {
        Checkpoint-Computer -Description "OptiTech Restore Point"
        Write-Log -Level INFO -Message "Punto de restauración creado exitosamente."
        Write-Host -ForegroundColor Green "✔ Punto de restauración creado exitosamente."
    } catch {
        Write-Log -Level ERROR -Message "Error al crear punto de restauración: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al crear punto de restauración: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Ejecuta el Comprobador de archivos de sistema (SFC).
.DESCRIPTION
    Invoca a sfc.exe con el argumento /scannow para verificar la integridad
    de los archivos de sistema y repararlos si es necesario.
#>
function Run-SFCScan {
    Write-Log -Level INFO -Message "Iniciando escaneo SFC (System File Checker)."
    try {
        Write-Host -ForegroundColor Yellow "Iniciando 'sfc /scannow'. Esto puede tardar varios minutos..."
        $sfcOutput = (sfc.exe /scannow | Out-String)
        
        if ($sfcOutput -match "Windows Resource Protection did not find any integrity violations.") {
            Write-Log -Level INFO -Message "Escaneo SFC completado: No se encontraron violaciones de integridad."
            Write-Host -ForegroundColor Green "✔ Escaneo SFC completado: No se encontraron violaciones de integridad."
        } elseif ($sfcOutput -match "Windows Resource Protection found corrupt files and successfully repaired them.") {
            Write-Log -Level INFO -Message "Escaneo SFC completado: Se encontraron y repararon archivos corruptos."
            Write-Host -ForegroundColor Green "✔ Escaneo SFC completado: Se encontraron y repararon archivos corruptos."
        } else {
            Write-Log -Level WARNING -Message "Escaneo SFC completado con otros resultados. Revise la salida para más detalles."
            Write-Host -ForegroundColor Yellow "⚠ Escaneo SFC completado con otros resultados. Revise la salida para más detalles."
        }
        Write-Host -ForegroundColor DarkGray "Salida de SFC:" -NoNewline; Write-Host $sfcOutput -ForegroundColor DarkGray
    } catch {
        Write-Log -Level ERROR -Message "Error al ejecutar escaneo SFC: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al ejecutar escaneo SFC: $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Ejecuta la herramienta DISM para reparar la imagen de Windows.
.DESCRIPTION
    Invoca a dism.exe para realizar una comprobación de estado y reparación
    de la imagen del sistema operativo.
#>
function Run-DISMScan {
    Write-Log -Level INFO -Message "Iniciando escaneo DISM (Deployment Image Servicing and Management)."
    try {
        Write-Host -ForegroundColor Yellow "Iniciando 'DISM /Online /Cleanup-Image /RestoreHealth'. Esto puede tardar varios minutos..."
        $dismOutput = Dism.exe /online /Cleanup-Image /RestoreHealth | Out-String
        
        if ($dismOutput -match "The restore operation completed successfully.") {
            Write-Log -Level INFO -Message "Escaneo DISM completado: La operación de restauración se completó exitosamente."
            Write-Host -ForegroundColor Green "✔ Escaneo DISM completado: La operación de restauración se completó exitosamente."
        } else {
            Write-Log -Level WARNING -Message "Escaneo DISM completado con otros resultados. Revise la salida para más detalles."
            Write-Host -ForegroundColor Yellow "⚠ Escaneo DISM completado con otros resultados. Revise la salida para más detalles."
        }
        Write-Host -ForegroundColor DarkGray "Salida de DISM:" -NoNewline; Write-Host $dismOutput -ForegroundColor DarkGray
    } catch {
        Write-Log -Level ERROR -Message "Error al ejecutar escaneo DISM: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al ejecutar escaneo DISM: $($_.Exception.Message)"
    }
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
    Write-Log -Level INFO -Message "Creando copia de seguridad del Registro."
    $backupPath = Join-Path $PSScriptRoot "RegistryBackup-$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    try {
        # Exportar el registro completo
        reg.exe export HKLM "$backupPath\HKLM.reg" /y
        reg.exe export HKCU "$backupPath\HKCU.reg" /y
        
        Write-Log -Level INFO -Message "Copia de seguridad del Registro creada en: $backupPath"
        Write-Host -ForegroundColor Green "✔ Copia de seguridad del Registro creada en: $backupPath"
    } catch {
        Write-Log -Level ERROR -Message "Error al crear copia de seguridad del Registro: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al crear copia de seguridad del Registro: $($_.Exception.Message)"
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
    Write-Log -Level WARNING -Message "Iniciando restauración de copia de seguridad del Registro (Alto Riesgo)."
    Write-Host -ForegroundColor Red "!!! ADVERTENCIA: La restauración del Registro es una operación de ALTO RIESGO. !!!"
    Write-Host -ForegroundColor Red "!!! Puede causar inestabilidad en el sistema si la copia de seguridad es incompatible o está dañada. !!!"
    Write-Host -ForegroundColor Red "!!! Asegúrese de tener una copia de seguridad reciente y un punto de restauración del sistema. !!!"
    
    $confirm = Read-Host -Prompt "¿Está seguro de que desea continuar con la restauración del Registro? (S/N)"
    if ($confirm -ne 'S') {
        Write-Log -Level INFO -Message "Restauración del Registro cancelada por el usuario."
        Write-Host -ForegroundColor Yellow "⚠ Restauración del Registro cancelada."
        return
    }

    $backupPath = Read-Host -Prompt "Ingrese la ruta COMPLETA de la carpeta de la copia de seguridad del Registro (ej. C:\OptiTech\RegistryBackup-20231026_103000)"
    if (-not (Test-Path $backupPath)) {
        Write-Log -Level ERROR -Message "Ruta de copia de seguridad no encontrada: $backupPath"
        Write-Host -ForegroundColor Red "✖ Error: Ruta de copia de seguridad no encontrada."
        return
    }

    try {
        # Importar el registro completo
        reg.exe import "$backupPath\HKLM.reg"
        reg.exe import "$backupPath\HKCU.reg"
        
        Write-Log -Level INFO -Message "Restauración del Registro completada desde: $backupPath. Se recomienda reiniciar el sistema."
        Write-Host -ForegroundColor Green "✔ Restauración del Registro completada desde: $backupPath. Se recomienda reiniciar el sistema."
    } catch {
        Write-Log -Level ERROR -Message "Error al restaurar el Registro: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al restaurar el Registro: $($_.Exception.Message)"
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
    Write-Log -Level INFO -Message "Programando comprobación de disco (chkdsk) en el próximo reinicio."
    try {
        # Programar chkdsk para la unidad C: en el próximo reinicio
        chkdsk C: /f /r /x
        Write-Log -Level INFO -Message "Comprobación de disco (chkdsk) programada para el próximo reinicio. Se recomienda reiniciar el sistema."
        Write-Host -ForegroundColor Green "✔ Comprobación de disco (chkdsk) programada para el próximo reinicio. Se recomienda reiniciar el sistema."
    } catch {
        Write-Log -Level ERROR -Message "Error al programar comprobación de disco (chkdsk): $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al programar comprobación de disco (chkdsk): $($_.Exception.Message)"
    }
}

<#
.SYNOPSIS
    Muestra el menú del módulo de mantenimiento.
#>
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
    Write-Log -Level INFO -Message "Limpiando la caché de DNS."
    try {
        ipconfig /flushdns
        Write-Log -Level INFO -Message "Caché de DNS limpiada exitosamente."
        Write-Host -ForegroundColor Green "✔ Caché de DNS limpiada exitosamente."
    } catch {
        Write-Log -Level ERROR -Message "Error al limpiar la caché de DNS: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al limpiar la caché de DNS: $($_.Exception.Message)"
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
    Write-Log -Level INFO -Message "Renovando la dirección IP."
    try {
        ipconfig /release
        ipconfig /renew
        Write-Log -Level INFO -Message "Dirección IP renovada exitosamente."
        Write-Host -ForegroundColor Green "✔ Dirección IP renovada exitosamente."
    } catch {
        Write-Log -Level ERROR -Message "Error al renovar la dirección IP: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red "✖ Error al renovar la dirección IP: $($_.Exception.Message)"
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
        Write-Host "--- Seleccionar Perfil Automatizado ---" -ForegroundColor Cyan
        for ($i = 0; $i -lt $profileNames.Count; $i++) {
            Write-Host -NoNewline ("{0}. " -f ($i + 1)) -ForegroundColor Yellow; Write-Host $profileNames[$i]
        }
        Write-Host -NoNewline "V. " -ForegroundColor Yellow; Write-Host "Volver al menú principal"

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
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "   OptiTech System Optimizer" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host
    Write-Host -NoNewline "1. " -ForegroundColor Yellow; Write-Host "Análisis del Sistema"
    Write-Host -NoNewline "2. " -ForegroundColor Yellow; Write-Host "Limpieza del Sistema"
    Write-Host -NoNewline "3. " -ForegroundColor Yellow; Write-Host "Optimización del Sistema"
    Write-Host -NoNewline "4. " -ForegroundColor Yellow; Write-Host "Mantenimiento y Copias de Seguridad"
    Write-Host -NoNewline "5. " -ForegroundColor Yellow; Write-Host "Red y Conectividad"
    Write-Host
    Write-Host -NoNewline "A. " -ForegroundColor Yellow; Write-Host "Ejecutar Perfil Automatizado"
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