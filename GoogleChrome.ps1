# Este Script instala la última versión de Google Chrome.
# La instalación se realiza sin intervención del usuario y al finalizar borra el instalador descargado.
# Ejecute en PowerShell como Administrador. 
# @andriuzha

# Definiendo el directorio de descarga 
$LocalTempDir = $env:TEMP; 

#Solicitando la descarga y el guardando en el directorio definido
$ChromeInstaller = "ChromeInstaller.exe"; 
(new-object    System.Net.WebClient).DownloadFile('https://dl.google.com/chrome/install/latest/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller"); 

#Realizando la instalación silenciosa 
& "$LocalTempDir\$ChromeInstaller" /silent /install; $Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; 

#Mostrando el mensaje de espera hasta que el proceso de instalción termine
If ($ProcessesFound) { "Ejecutando: $($ProcessesFound -join ', ') Espere por favor..." | Write-Host; Start-Sleep -Seconds 5 } 

#Borrando el instalador temporal 
else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } }Until (!$ProcessesFound)


