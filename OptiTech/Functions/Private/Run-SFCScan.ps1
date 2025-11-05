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
