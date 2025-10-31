# OptiTech System Optimizer (PowerShell)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Windows](https://img.shields.io/badge/OS-Windows_11-blue.svg)![License](https://img.shields.io/badge/License-MIT-green.svg)

**OptiTech System Optimizer** es un módulo de PowerShell de nivel empresarial diseñado para la limpieza, optimización y mantenimiento de sistemas operativos Windows 11. La herramienta proporciona un conjunto de funciones robustas y configurables que pueden ser ejecutadas de forma desatendida para la gestión de flotas de equipos a gran escala.

---

## ✨ Características Principales

El módulo se organiza en varias categorías de funciones para una administración granular del sistema:

*   **Análisis del Sistema:** Obtiene información detallada sobre el sistema operativo, hardware y servicios.
*   **Limpieza Profunda:** Elimina archivos temporales, cachés (Windows Update, Microsoft Teams), vacía la papelera de reciclaje y limpia componentes obsoletos de WinSxS.
*   **Optimización de Rendimiento:** Ajusta la configuración de efectos visuales, gestiona servicios no esenciales y aplica planes de energía de alto rendimiento.
*   **Mantenimiento y Seguridad:** Permite la creación de puntos de restauración, ejecución de `sfc` y `DISM`, y la gestión de copias de seguridad del Registro de Windows.
*   **Red y Conectividad:** Incluye utilidades para limpiar la caché de DNS y renovar la configuración IP.

## 🚀 Empezando

### Prerrequisitos

*   Windows 11
*   PowerShell 5.1 o superior
*   Ejecución con privilegios de Administrador

### Instalación

1.  Clona este repositorio en tu máquina local:
    ```powershell
    git clone https://github.com/Michel-Macias/OptiTech-System-Optimizer-PowerShell.git
    ```
2.  Importa el módulo en tu sesión de PowerShell:
    ```powershell
    Import-Module -Name .\OptiTech\OptiTech.psd1
    ```

## ⚙️ Uso

La función principal del módulo es `Invoke-OptiTech`. Ha sido diseñada para una ejecución automatizada y desatendida.

### Ejemplos

Ejecutar un perfil de limpieza profunda predefinido:
```powershell
Invoke-OptiTech -Profile LimpiezaProfunda -Verbose
```

Ejecutar una tarea de optimización específica:
```powershell
Invoke-OptiTech -Task Set-PerformanceVisualEffects, Set-HighPerformancePowerPlan
```

Generar un informe en una ruta de red centralizada:
```powershell
Invoke-OptiTech -Profile LimpiezaCompleta -LogPath \servidor\logs\equipo01
```

## 🔧 Configuración

El comportamiento del módulo puede ser personalizado a través del archivo `config.json`. Este archivo permite gestionar de forma centralizada parámetros como la lista de servicios a deshabilitar sin necesidad de modificar el código fuente.

```json
{
  "ServicesToDisable": [
    "dmwappushservice",
    "diagtrack"
  ],
  "Profiles": {
    "LimpiezaProfunda": [
      "Clear-SystemTempFiles",
      "Clear-UserTempFiles",
      "Invoke-ClearRecycleBin",
      "Clear-UpdateCache",
      "Clear-WinSxSComponent",
      "Clear-TeamsCache"
    ]
  }
}
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un *issue* para discutir cambios importantes o envía un *pull request* con tus mejoras.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
