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
