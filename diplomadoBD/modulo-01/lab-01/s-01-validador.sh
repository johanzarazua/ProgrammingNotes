#!/bin/bash
source ./s-00-funciones-validacion.sh

#header
fv_header;

echo "Validador Tema 01 - Ejercicio práctico 01"
echo ""

#valida el usuario de ejecución
[ "${USER}" != "oracle" -a "${USER}" != "root" ]; condicion=$?

fv_assert 1 $condicion "usuario != oracle, root" "${USER}" \
  "Usuario de ejecución correcto: ${USER}" "Usuario de ejecución inválido"

#valida el lenguaje
[ "en_US.utf8" = "${LANG}" -o "en_US.UTF-8" = "${LANG}"  ]; condicion=$?
fv_assert 2 $condicion "en_US.utf8 o en_US.UTF-8" "${LANG}" \
  "Configuración de idioma válido: ${LANG}" \
  "Configuración inválida del idioma"

#valida el nombre del host
[[ "${HOSTNAME}" =~ (pc-)* ]]; condicion=$?
fv_assert 3 $condicion "pc-*\.fi\.unam" "${HOSTNAME}" \
  "Host name válido: ${HOSTNAME}" \
  "Host name inválido"

#sudo echo "Proporcione password del usuario ${USER}"
hostname=`cat /etc/hostname`
os=`cat /etc/os-release | grep PRETTY_NAME`
vboxguest=`lsmod | grep vboxguest`

host_length=${#hostname}
user_length=${#USER}
hash=$(($host_length+$user_length))

echo "$(fv_list_prefix 4) os  = $os" 
echo "$(fv_list_prefix 5) vb  = $vboxguest"
echo "$(fv_list_prefix 6) hsh = $hash" 

echo "$(fv_list_prefix 7) Validación concluida."
