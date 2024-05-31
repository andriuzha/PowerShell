#Este script copia archivos y todo el contenido de directorios de una forma sencilla
#@andriuzha

#Definimos el directorio de origen
$Origen = Read-Host -Prompt 'Ingresa la carpeta de origen'

#Definimos el directorio de destino
$Destino = Read-Host -Prompt 'Ingresa la carpeta de destino'

#Ejecutando la copia 
robocopy $Origen $Destino /e /w:5 /r:2 /COPY:DATSOU /DCOPY:DAT /MT

#Opciones de copia
## /e Copia subdirectorios vacíos.
## /w:5 Establece 5 segundos de espera antes de intentar copiar un archivo con errores. 
## /r2 Puede repetir el intento hasta 2 veces.
## /COPY:DATSOU: Copia solo los atributos del archivo necesarios para preservar la fecha de última modificación (Date Accessed) y atributos de solo lectura (Owner, Archive) de los directorios
##/DCOPY:DAT: Copia solo los atributos del directorio necesarios para preservar la fecha de última modificación (Date Accessed) y atributos de solo lectura (Owner, Archive) de los directorios.
## /MT: Usa subprocesos múltiples para acelerar la copia (especialmente útil para directorios grandes).
