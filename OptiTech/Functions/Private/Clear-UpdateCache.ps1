<#
.SYNOPSIS
    Limpia la cache de descargas de Windows Update.
.DESCRIPTION
    Detiene el servicio de Windows Update, elimina los archivos de la cache de descargas
    y reinicia el servicio. Esto puede solucionar problemas con Windows Update y liberar espacio.
#>
function Clear-UpdateCache {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    if (-not (Test-IsAdmin)) {
        $errorMessage = "Se requieren privilegios de Administrador para limpiar la cache de Windows Update."
        Write-Log -Level ERROR -Message $errorMessage
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
        return
    }

    Write-Log -Level INFO -Message "Iniciando limpieza de la cache de Windows Update..."
    Write-Host -ForegroundColor White "`nIniciando limpieza de la cache de Windows Update..."

    $serviceName = "wuauserv"
    $updateCachePath = "$env:SystemRoot\SoftwareDistribution\Download"

    try {
        Write-Host -ForegroundColor White "- Deteniendo el servicio de Windows Update ($serviceName)..."
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
        Write-Log -Level INFO -Message "Servicio $serviceName detenido."

        if ($pscmdlet.ShouldProcess($updateCachePath, "Limpiar cache de Windows Update")) {
            Write-Host -ForegroundColor White "- Limpiando la cache en $updateCachePath..."
            $items = Get-ChildItem -Path $updateCachePath -Recurse
            if ($items) {
                Remove-Item -Path $items.FullName -Force -Recurse -ErrorAction Stop
                $message = "Cache de Windows Update limpiada."
                Write-Log -Level INFO -Message $message
                Write-Host -ForegroundColor Green "  (OK) $message"
            } else {
                $message = "La cache de Windows Update ya estaba vacia."
                Write-Log -Level INFO -Message $message
                Write-Host -ForegroundColor Green "  (OK) $message"
            }
        }

    } catch {
        $errorMessage = "Ocurrio un error durante la limpieza de la cache de Windows Update."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_"
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"

    } finally {
        Write-Host -ForegroundColor White "- Reiniciando el servicio de Windows Update ($serviceName)..."
        Start-Service -Name $serviceName -ErrorAction SilentlyContinue
        Write-Log -Level INFO -Message "Servicio $serviceName iniciado."
    }

    $finalMessage = "Proceso de limpieza de cache de Windows Update completado."
    Write-Log -Level INFO -Message $finalMessage
    Write-Host -ForegroundColor Green "`n(OK) $finalMessage"
}
