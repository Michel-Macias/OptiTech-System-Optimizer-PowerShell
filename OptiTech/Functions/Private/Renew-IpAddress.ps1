<#
.SYNOPSIS
    Renueva la concesión de la dirección IP.
.DESCRIPTION
    Ejecuta ipconfig /renew para solicitar una nueva dirección IP al servidor DHCP.
    Útil para solucionar problemas de conectividad de red.
#>
function Renew-IpAddress {
    [CmdletBinding()]
    param()

    Write-Log -Level INFO -Message "Iniciando liberación y renovación de la dirección IP..." | Out-Null
    Write-Host -ForegroundColor White "`nLiberando y renovando la dirección IP..."

    try {
        Write-Host -ForegroundColor White "- Liberando la concesión de IP actual (ipconfig /release)..."
        ipconfig /release | Out-Null
        Write-Log -Level INFO -Message "IP liberada." | Out-Null

        Write-Host -ForegroundColor White "- Renovando la concesión de IP (ipconfig /renew)..."
        ipconfig /renew | Out-Null
        Write-Log -Level INFO -Message "IP renovada." | Out-Null

        if ($LASTEXITCODE -eq 0) {
            $message = "La dirección IP ha sido liberada y renovada con éxito."
            Write-Log -Level INFO -Message $message | Out-Null
            Write-Host -ForegroundColor Green "(OK) $message"

            Write-Host -ForegroundColor White "`n--- Nueva Configuración de Red ---"
            $ipConfig = Get-NetIPConfiguration | Select-Object -ExpandProperty IPv4Address | Where-Object {$_.IPAddress -ne "127.0.0.1" -and $_.IPAddress -notlike "169.254.*"}
            if ($ipConfig) {
                foreach ($ip in $ipConfig) {
                    Write-Host -ForegroundColor Green "  Dirección IP: $($ip.IPAddress)"
                    Write-Host -ForegroundColor Green "  Máscara de Subred: $($ip.PrefixLength)"
                    # Get-NetIPConfiguration doesn't directly show Gateway and DNS per IPAddress object, need to get it from parent object
                    $adapterConfig = Get-NetIPConfiguration -InterfaceIndex $ip.InterfaceIndex
                    if ($adapterConfig.IPv4DefaultGateway) {
                        Write-Host -ForegroundColor Green "  Puerta de Enlace: $($adapterConfig.IPv4DefaultGateway.NextHop)"
                    }
                    if ($adapterConfig.DNSServer) {
                        Write-Host -ForegroundColor Green "  Servidores DNS: $(($adapterConfig.DNSServer.IPAddress | Select-Object -Unique) -join ", ")"
                    }
                    Write-Host "" # Empty line for readability
                }
            } else {
                Write-Host -ForegroundColor Yellow "No se pudo obtener la nueva configuración de IP."
            }
        } else {
            $errorMessage = "El comando ipconfig finalizó con un código de error. Es posible que la renovación no haya sido exitosa."
            Write-Log -Level WARNING -Message $errorMessage | Out-Null
            Write-Host -ForegroundColor Yellow "(AVISO) $errorMessage"
        }
    } catch {
        $errorMessage = "Ocurrió un error durante el proceso de liberación/renovación de IP."
        Write-Log -Level ERROR -Message "$errorMessage Detalle: $_" | Out-Null
        Write-Host -ForegroundColor Red "(ERROR) $errorMessage"
    }
}

