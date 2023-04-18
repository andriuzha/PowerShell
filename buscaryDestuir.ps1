# Este escript busca repartidos a lo largo de dos discos o directorios diferentes
# Borrara tras una confirmación los archivos en la dirección original 
# (Esto se puede editar facilmente, leer los comentarios)
# @andriuzha

# Reemplaza las direcciones de los discos por las tuyas: 
$directorioAntiguo = "Disco1:\carpeta" 
$directorioNuevo = "Disco2:\carpeta" 

# Obteneiendo todos los archivos de ambos directorios: 
$archivosAntiguos = Get-ChildItem -Path $directorioAntiguo -Recurse -File 
$archivosNuevos = Get-ChildItem -Path $directorioNuevo -Recurse -File 

for($i=0; $i -lt $archivosAntiguos.length; $i++){ 
	$j=0 while($true){ 
		# Si el tamaño del archivo y la hora de la última modificación coinciden... 
		if($($archivosAntiguos[$i]).length -eq $($archivosNuevos[$j]).length -and $($archivosAntiguos[$i]).lastWriteTime -eq $($archivosNuevos[$j]).lastWriteTime){ 
		# Obteniendo los Hash de los archivos (con SHA1 debería ser suficiente) 
		$archivosAntiguos_hash = Get-FileHash -Path $($archivosAntiguos[$i]).FullName -Algorithm SHA1 | ForEach-Object {$_.Hash} $archivosNuevos_hash = Get-FileHash -Path $($archivosNuevos[$j]).FullName -Algorithm SHA1 | ForEach-Object {$_.Hash} 
		# Si los Hash también coinciden... 
		if($archivosAntiguos_hash -eq $archivosNuevos_hash){ 
		# Eliminando los archivos antiguos (retira la bandera -Confirm para evitar confirmar cada archivo) 
		# Si deseas verificar los archivos antes de eliminaros descomenta la línea que contiene ".DUPLICADO"
		# Esto renobrará los archivos
		# Rename-Item -Path $($archivosAntiguos[$i]).FullName -NewName "$($archivosAntiguos[$i]).Name.DUPLICADO" 
		Remove-Item -Path $($archivosAntiguos[$i]).FullName -Confirm 
		Write-Host "DELETING`t$($archivosAntiguos[$i]).FullName" -ForegroundColor red 
		break 
		} 

	# Si los archivos no son iguales entonces... 
	}else{ # si el archivo antiguo se compara con todos los archivos nuevos, verifique el siguiente archivo antiguo 
			if($j -ge $archivosNuevos.length){ 
				break 
			}	 
		} 
		$j++ 
	} 
}
