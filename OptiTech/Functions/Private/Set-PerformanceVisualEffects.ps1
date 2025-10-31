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
