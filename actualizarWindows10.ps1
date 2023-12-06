###############################################################################
# Script para actualización de Windows 10
# Author: @andriuzha
# Version: 1.0.1
# 06.12.2023
# https://github.com/andriuzha/
###############################################################################

# Asignando las políticas de ejecución e instakando los módulos necesarios
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
Install-PackageProvider -Name NuGet -Force
Import-PackageProvider -Name NuGet

# Actualizando el PSGallery de los repositorios
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Get-PSRepository -Name PSGallery | Format-List * -Force

# Listando todos los módulos disponibles disponibles para actualizarse
Write-Output "Listando módulos disponibles ..."
Get-InstalledModule

# Instanado los módulos nque necesitamos 
Write-Output "Instalando módulos ..."
Install-Module -Name PSWindowsUpdate -Force

# Importando los módulos
Import-Module -Name PSWindowsUpdate

# Listando los comandos de soporte de los módulos
Get-Command -Module PSWindowsUpdate

# Verificando la disponibilidad del servicio Microsoft Update. En caso de no estar diponible, se habilita
$MicrosoftUpdateServiceId = "7971f918-a847-4430-9279-4a52d1efe18d"
If ((Get-WUServiceManager -ServiceID $MicrosoftUpdateServiceId).ServiceID -eq $MicrosoftUpdateServiceId) { Write-Output "El servicio Microsoft Update está habilitado." }
Else { Add-WUServiceManager -ServiceID $MicrosoftUpdateServiceId -Confirm:$true }

# Reintentado la verificación del servicio nuevamente. Si no esta disponible, se muestra el error
If (!((Get-WUServiceManager -ServiceID $MicrosoftUpdateServiceId).ServiceID -eq $MicrosoftUpdateServiceId)) { Throw "ERROR: El servicio Microsoft Update no está disponible." }

# Forzar la instalación de actualizaciones y reiniciar (de ser necesario)
Write-Output "Instalando las actualizaciones, es posible que el equipo se reinicie ..."
Write-Output "El regristo correspondiente será almacenado en su carpeta C:\"
Get-WUInstall -MicrosoftUpdate -AcceptAll -Download -Install -AutoReboot | Out-File "C:\($env.computername-Get-Date -f yyyy-MM-dd)-MSUpdates.log" -Force
