# OptiTech System Optimizer (Versión Interactiva con Menú)

Este documento describe el uso de la versión de `OptiTech.ps1` que opera a través de un menú interactivo en la consola, pero que también incorpora potentes capacidades de automatización.

---

## 🧠 Filosofía de Diseño: Lo Mejor de Dos Mundos

Esta versión mantiene la facilidad de uso de una interfaz de menú para técnicos que trabajan directamente en una máquina, al tiempo que introduce la capacidad de ejecutar secuencias de tareas predefinidas (perfiles) de forma automatizada. Es una solución híbrida que combina la simplicidad interactiva con la potencia de la automatización.

## 🚀 Cómo Usar el Script

### 1. Modo Interactivo (Uso Manual)

Es el modo de uso tradicional. Simplemente ejecuta el script en una consola de PowerShell con privilegios de administrador:

```powershell
.\OptiTech.ps1
```

Aparecerá un menú principal desde el cual podrás navegar a los diferentes submódulos (Análisis, Limpieza, Optimización, etc.) y seleccionar las tareas que deseas realizar una por una.

### 2. Modo Automatizado (Ejecución de Perfiles)

Esta es la nueva funcionalidad clave. Permite ejecutar un conjunto de tareas predefinidas sin necesidad de navegar por los menús.

1.  Ejecuta el script `.\OptiTech.ps1`.
2.  En el menú principal, selecciona la opción **`A. Ejecutar Perfil Automatizado`**.
3.  El script leerá los perfiles disponibles en el archivo `config.json` y te los presentará en una lista.
4.  Selecciona el número del perfil que deseas ejecutar (por ejemplo, `LimpiezaProfunda`).
5.  El script ejecutará todas las tareas asociadas a ese perfil de forma secuencial y sin más interacción.
6.  Al finalizar, se mostrará un resumen en la consola con los resultados de la operación.

## 🔧 Configuración de Perfiles y Tareas

La potencia del modo automatizado reside en el archivo `config.json`. Aquí es donde defines qué tareas se ejecutan en cada perfil.

### Estructura del `config.json`

*   **`ServicesToDisable`**: Una lista de los nombres de los servicios que la función "Gestionar servicios no esenciales" deshabilitará.
*   **`Profiles`**: Un objeto que contiene uno o más perfiles de ejecución.
    *   Cada **perfil** (ej. `LimpiezaProfunda`) es una lista de nombres de funciones que se ejecutarán en orden.

### Ejemplo de `config.json`

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
    ],
    "OptimizacionEstandar": [
        "Set-PerformanceVisualEffects",
        "Set-HighPerformancePowerPlan"
    ]
  }
}
```

Para personalizar la ejecución, simplemente edita este archivo JSON. Por ejemplo, si no quieres que el perfil `LimpiezaProfunda` elimine la caché de Teams, simplemente borra la línea `"Clear-TeamsCache"` de la lista.
