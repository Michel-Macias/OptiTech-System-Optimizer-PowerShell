<#
.SYNOPSIS
    Ajusta la configuracion de efectos visuales de Windows para un mejor rendimiento.
.DESCRIPTION
    Modifica la clave de registro 'VisualFxSetting' a '2' (Mejor rendimiento)
    y reactiva el suavizado de fuentes para mantener la legibilidad del texto.
#>
function Set-PerformanceVisualEffects {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param()

    Write-Log -Level INFO -Message "Configurando efectos visuales para un rendimiento optimo..." | Out-Null
    Write-Host -ForegroundColor White "`nConfigurando efectos visuales para un rendimiento optimo..."

    try {
        if ($pscmdlet.ShouldProcess("Configuracion de UI de Windows", "Ajustar para mejor rendimiento")) {
            # Deshabilita todos los efectos visuales (el valor 2 significa "Ajustar para obtener el mejor rendimiento")
            $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
            Set-ItemProperty -Path $key -Name "VisualFxSetting" -Value 2 -ErrorAction Stop

            # Reactiva algunos efectos esenciales para una buena experiencia de usuario
            # Habilitar suavizado de fuentes
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -ErrorAction Stop
            # Habilitar miniaturas en lugar de iconos
            $advKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
            Set-ItemProperty -Path $advKey -Name "IconsOnly" -Value 0 -ErrorAction Stop

            $message = "Efectos visuales configurados para un rendimiento optimo."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"
        }
    } catch {
        $errorMessage = "Ocurrio un error al configurar los efectos visuales."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
    }
}

