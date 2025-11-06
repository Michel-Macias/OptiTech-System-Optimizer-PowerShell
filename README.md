# OptiTech System Optimizer (PowerShell)

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)
![Windows](https://img.shields.io/badge/OS-Windows_11-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

**OptiTech System Optimizer** es un módulo de PowerShell de nivel empresarial diseñado para la limpieza, optimización y mantenimiento de sistemas operativos Windows 11. La herramienta proporciona un conjunto de funciones robustas y configurables que pueden ser ejecutadas de forma desatendida para la gestión de flotas de equipos a gran escala.

---

## 🧠 Filosofía de Diseño: De Interactivo a Automatizado

Este módulo es la evolución de un script interactivo basado en menús. El cambio a un modelo de comandos no interactivo es una decisión de diseño deliberada para satisfacer las necesidades de los entornos empresariales modernos.

El objetivo principal es la **automatización y la gestión a escala**. En lugar de requerir que un técnico navegue por menús en cada máquina, este módulo permite a los administradores de sistemas desplegar y ejecutar optimizaciones de forma remota y silenciosa en cientos o miles de equipos a través de herramientas como Microsoft Intune, System Center Configuration Manager (SCCM) o directivas de grupo (GPO).

La visibilidad y el control, antes proporcionados por el menú, se logran ahora a través de métodos más potentes y auditables.

## 🌳 Enfoques de Implementación

Este proyecto ofrece dos enfoques principales para la optimización del sistema, cada uno alojado en una rama de Git diferente para adaptarse a distintas necesidades:

*   **`main` (Módulo PowerShell - Automatización a Escala):**
    Esta es la rama principal y contiene el proyecto refactorizado como un módulo de PowerShell (`OptiTech.psd1`). Está diseñado para la automatización desatendida y la gestión de flotas de equipos a gran escala mediante comandos (`Invoke-OptiTech`). La documentación detallada para este enfoque se encuentra en este mismo `README.md`.

*   **`feat/menu-driven-enhancements` (Script Interactivo con Automatización):**
    Esta rama contiene una evolución del script original (`OptiTech.ps1`) que mantiene una interfaz de menú interactiva para uso manual, pero que ha sido mejorada con configuración externa y una opción para ejecutar perfiles de optimización automatizados directamente desde el menú. Es ideal para técnicos que trabajan directamente en una máquina.
    Para explorar esta versión, puedes cambiar a la rama con:
    ```bash
    git checkout feat/menu-driven-enhancements
    ```
    La guía de usuario específica para esta versión se encuentra en `README_Interactive.md` dentro de esa rama.

## ✨ Características Principales

*   **Análisis del Sistema:** Obtiene información detallada sobre el sistema operativo, hardware y servicios.
*   **Limpieza Profunda:** Elimina archivos temporales, cachés (Windows Update, Microsoft Teams), vacía la papelera de reciclaje y limpia componentes obsoletos de WinSxS.
*   **Optimización de Rendimiento:** Ajusta la configuración de efectos visuales, gestiona servicios no esenciales y aplica planes de energía de alto rendimiento.
*   **Mantenimiento y Seguridad:** Permite la creación de puntos de restauración, ejecución de `sfc` y `DISM`, y la gestión de copias de seguridad del Registro de Windows.
*   **Red y Conectividad:** Incluye utilidades para limpiar la caché de DNS y renovar la configuración IP.
*   **Manejo de Errores y Elevación de Privilegios:** Implementación robusta de manejo de errores y verificación/elevación automática de privilegios de administrador para asegurar la ejecución correcta de las tareas.

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

## 🚀 Uso Interactivo (Recomendado para técnicos)

Para una experiencia guiada, puedes utilizar el script interactivo `Start-OptiTech.ps1` que actúa como una interfaz amigable para el módulo.

1.  **Inicia el script** desde la raíz del proyecto en una terminal de PowerShell con privilegios de Administrador:
    ```powershell
    ./Start-OptiTech.ps1
    ```
2.  **Navega por los menús:** El script te presentará un menú principal para acceder a diferentes categorías de tareas:
    *   Análisis del Sistema
    *   Limpieza del Sistema
    *   Optimización del Sistema
    *   Mantenimiento y Copias de Seguridad
    *   Red y Conectividad
3.  **Ejecuta Perfiles Automatizados:** La opción `A` te permite ejecutar perfiles predefinidos en `config.json`. Para cada perfil, podrás **elegir el modo de ejecución**:
    *   **Simulación (WhatIf):** Muestra todos los cambios que se realizarían sin aplicar ninguno. Ideal para verificar las acciones de un perfil antes de ejecutarlo.
    *   **Aplicar Cambios:** Ejecuta las tareas de forma real. Por seguridad, te pedirá una confirmación final antes de proceder.

## ⚙️ Uso Avanzado (Línea de Comandos)

La función principal del módulo es `Invoke-OptiTech`. Aunque no hay un menú interactivo, el control y la visibilidad sobre las acciones realizadas son totales:

1.  **Control a través de la Configuración:** El archivo `config.json` define de forma transparente qué tareas se incluyen en cada perfil y qué parámetros se utilizan (por ejemplo, la lista de servicios a deshabilitar). El administrador tiene control total sobre el "qué" se ejecuta.

2.  **Control a través de Comandos:** El administrador elige explícitamente "cómo" ejecutar las tareas, ya sea mediante un perfil (`-Profile`) o tareas individuales (`-Task`).

3.  **Visibilidad en Tiempo Real (`-Verbose`):** Para ver en la terminal exactamente lo que el módulo está haciendo en cada momento, simplemente añade el parámetro `-Verbose` al comando. Esto proporciona un seguimiento en vivo de cada operación, reemplazando la necesidad de un menú.

4.  **Visibilidad Post-Ejecución (Informes):** Al finalizar, el módulo generará un resumen de las acciones completadas y los resultados obtenidos (funcionalidad de la Fase 4).

### Ejemplos

Ejecutar un perfil de limpieza profunda con seguimiento en tiempo real en la consola:
```powershell
Invoke-OptiTech -Profile LimpiezaProfunda -Verbose
```

Ejecutar una tarea de optimización específica:
```powershell
Invoke-OptiTech -Task Set-PerformanceVisualEffects, Set-HighPerformancePowerPlan
```

Generar un informe en una ruta de red centralizada:
```powershell
Invoke-OptiTech -Profile LimpiezaCompleta -LogPath \\servidor\logs\equipo01
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
