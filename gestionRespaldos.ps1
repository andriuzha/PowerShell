############################################################################
# Script de gestión de respaldos
# Crea y restaura backups de una carpeta llamada Respaldo alojada en C:
# Author: @andriuzha
# Versión 1.3
# 27 ene 2025
# https://github.com/andriuzha/
############################################################################


# Menú principal
function Show-Menu {
    Clear-Host
    Write-Host "============================================"
    Write-Host "Herramienta para la gestión de respaldos"
    Write-Host "@andriuzha"
    Write-Host "============================================"
    Write-Host "1. Crear un respaldo"
    Write-Host "2. Restaurar un respaldo"
    Write-Host "3. Salir"
    Write-Host "============================================"
}

# Función para calcular el hash de un archivo
function Get-FileHash256 {
    param (
        [string]$FilePath
    )
    return (Get-FileHash -Algorithm SHA256 -Path $FilePath).Hash
}

# Función para crear un respaldo
function Create-Backup {
    # Comprobar si existe la carpeta C:\backup
    if (-not (Test-Path -Path "C:\respaldo")) {
        Write-Host "La carpeta C:\respaldo no existe. Compruebe la ruta y presione Enter para continuar."
        Read-Host
        return
    }

    # Obtener la ruta del script (disco USB)
    $scriptPath = $PSScriptRoot
    $backupDate = Get-Date -Format "ddMMyyyy"
    $backupFileName = "${backupDate}_respaldo.zip"
    $localZipPath = Join-Path -Path "C:\" -ChildPath $backupFileName
    $usbZipPath = Join-Path -Path $scriptPath -ChildPath $backupFileName

    # Crear el archivo ZIP sin compresión en C:\
    try {
        Compress-Archive -Path "C:\respaldo\*" -DestinationPath $localZipPath -CompressionLevel NoCompression
        Write-Host "Respaldo creado temporalmente en: $localZipPath"
    } catch {
        Write-Host "Error al crear el respaldo: $_"
        return
    }

    # Calcular el hash del archivo ZIP en C:\
    $localHash = Get-FileHash256 -FilePath $localZipPath

    # Copiar el archivo ZIP al disco USB
    try {
        Copy-Item -Path $localZipPath -Destination $usbZipPath -Force
        Write-Host "Respaldo copiado al disco USB: $usbZipPath"
    } catch {
        Write-Host "Error al copiar el respaldo al disco USB: $_"
        Remove-Item -Path $localZipPath -Force
        return
    }

    # Calcular el hash del archivo ZIP en el disco USB
    $usbHash = Get-FileHash256 -FilePath $usbZipPath

    # Comparar los hash
    if ($localHash -ne $usbHash) {
        Write-Host "Los hash no coinciden. El respaldo ha tenido un problema."
        Remove-Item -Path $usbZipPath -Force
        Write-Host "El archivo $backupFileName ha sido borrado del disco USB."
        $choice = Read-Host "¿Desea reintentar? (S/N)"
        if ($choice -eq "S" -or $choice -eq "s") {
            Create-Backup
        } else {
            exit
        }
    } else {
        Remove-Item -Path $localZipPath -Force
        Write-Host "El respaldo ha sido terminado con éxito. Presione Enter para continuar."
        Read-Host
    }
}

# Función para restaurar un respaldo
function Restore-Backup {
    # Obtener la ruta del script (disco USB)
    $scriptPath = $PSScriptRoot
    $backupFiles = Get-ChildItem -Path $scriptPath -Filter *.zip

    if ($backupFiles.Count -eq 0) {
        Write-Host "No se encontraron archivos de respaldo en la unidad USB."
        Read-Host
        return
    }

    # Mostrar archivos disponibles
    Write-Host "Seleccione el archivo de respaldo a restaurar:"
    for ($i = 0; $i -lt $backupFiles.Count; $i++) {
        Write-Host "$($i + 1). $($backupFiles[$i].Name)"
    }

    # Solicitar selección del usuario
    $selectedIndex = Read-Host "Ingrese el número del archivo"
    if (-not ($selectedIndex -match "^\d+$") -or $selectedIndex -lt 1 -or $selectedIndex -gt $backupFiles.Count) {
        Write-Host "Opción no válida. Presione Enter para continuar."
        Read-Host
        Restore-Backup
        return
    }

    $selectedFile = $backupFiles[$selectedIndex - 1]
    $tempZipPath = Join-Path -Path "C:\" -ChildPath $selectedFile.Name

    # Copiar el archivo ZIP a C:\
    Copy-Item -Path $selectedFile.FullName -Destination $tempZipPath

    # Comprobar los hash
    $sourceHash = Get-FileHash256 -FilePath $selectedFile.FullName
    $destinationHash = Get-FileHash256 -FilePath $tempZipPath

    if ($sourceHash -ne $destinationHash) {
        Write-Host "Los hash no coinciden. La restauración ha tenido un problema."
        Remove-Item -Path $tempZipPath -Force
        Write-Host "El archivo $($selectedFile.Name) ha sido borrado."
        $choice = Read-Host "¿Desea reintentar? (S/N)"
        if ($choice -eq "S" -or $choice -eq "s") {
            Restore-Backup
        } else {
            exit
        }
    } else {
        # Extraer el contenido del ZIP
        $extractPath = Join-Path -Path "C:\" -ChildPath ($selectedFile.BaseName)
        Expand-Archive -Path $tempZipPath -DestinationPath $extractPath -Force
        Remove-Item -Path $tempZipPath -Force
        Write-Host "La restauración ha terminado con éxito. Presione Enter para continuar."
        Read-Host
    }
}

# Bucle principal del script
while ($true) {
    Show-Menu
    $choice = Read-Host "Seleccione una opción"
    switch ($choice) {
        1 { Create-Backup }
        2 { Restore-Backup }
        3 { exit }
        default {
            Write-Host "Opción no válida. Presione Enter para continuar."
            Read-Host
        }
    }
}
