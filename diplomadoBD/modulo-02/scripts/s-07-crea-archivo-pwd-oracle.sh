# @Autor: Johan Axel Zarazua Ramirez 
# @Fecha creación: 10/septiembre/2022 
# @Descripción: Archivo de passwords

#!/bin/bash
echo "moviendo el archivo de passwors a /home/oracle/backups"
mkdir -p /home/oracle/backups
mv "${ORACLE_HOME}"/dbs/orapwjzrdip01 /home/oracle/backups

echo "creando nuevo archivo de passwords, usar [admin1234#]"
orapwd \
  file='${ORACLE_HOME}/dbs/orapwjzrdip01' \
  force=Y \
  format=12.2 \
  SYS=password

echo "comprobando existencia"
ls -l "${ORACLE_HOME}"/dbs/orapwjzrdip01