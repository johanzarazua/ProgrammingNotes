# @Autor: Johan Axel Zarazua Ramirez 
# @Fecha creación: 10/febrero/2023 
# @Descripción: Script para levantar instancia de una cdb

#!/bin/bash

#Parametros
cdb="${1}"

if [ -z "${cdb}" ]; then
  echo "Error: indicar el CDB name a inciar"
  exit 1;
fi;

password="${2}"
if [ -z "${password}" ]; then
  echo "Error: indicar el password de sys"
  exit 1;
fi;

echo "Iniciando ${cdb}"
export ORACLE_SID="${cdb}"
sqlplus sys/${password} as sysdba <<EOF
  startup
  show user
  exit;
EOF