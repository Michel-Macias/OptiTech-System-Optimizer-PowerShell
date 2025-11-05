<#
.SYNOPSIS
    Ajusta la configuración de efectos visuales de Windows para un mejor rendimiento.
.DESCRIPTION
    Modifica la clave de registro 'VisualFxSetting' a '2' (Mejor rendimiento)
    y reactiva el suavizado de fuentes para mantener la legibilidad del texto.
#>
function Set-PerformanceVisualEffects {
    Write-Log -Level INFO -Message "Iniciando ajuste de efectos visuales..." | Out-Null
    Write-Host -ForegroundColor White "`nAjustando efectos visuales para mejor rendimiento..."

    try {
        # El valor '2' corresponde a "Ajustar para obtener el mejor rendimiento".
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFxSetting" -Value 2 -ErrorAction Stop
        # Se reactiva el suavizado de fuentes (ClearType) para no sacrificar la legibilidad.
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value 2 -ErrorAction Stop
        
        $message = "Efectos visuales ajustados para 'Mejor Rendimiento' (con suavizado de fuentes)."
        Write-Log -Level INFO -Message "Efectos visuales ajustados. Se recomienda reiniciar el explorador o la sesión." | Out-Null
        Write-Host -ForegroundColor Green "✔ $message"
        Write-Host -ForegroundColor Yellow "Para que todos los cambios surtan efecto, se recomienda reiniciar la sesión de usuario."
    }
    catch {
        $errorMessage = "Ocurrió un error al ajustar los efectos visuales: $_"
        Write-Log -Level ERROR -Message $errorMessage | Out-Null
        Write-Host -ForegroundColor Red "❌ $errorMessage"
    }
}
