# --@Autor: Johan Axel Zarazua Ramirez 
# --@Fecha creación: 23/septiembre/2022 
# --@Descripción: Creacion del archivo de passwords para una nueva instancia 
#!/bin/bash

echo "creando archivo de passwords para instancia 2"

echo "Configurando ORACLE_SID"
export ORACLE_SID=jzrdip02
echo ${ORACLE_SID}

archivoPwd="orapw${ORACLE_SID}"

echo "Creando archivo de passwords"

if [ -f "${ORACLE_HOME}/dbs/${archivoPwd}" ]; then
  echo "El archivo existe, se va a sobreescribir..."
fi;

orapwd FILE="${ORACLE_HOME}/dbs/${archivoPwd}" \
  FORCE=Y \
  FORMAT=12.2 \
  SYS=password

echo "comprobando existencia del archivo"
ls -l ${ORACLE_HOME}/dbs/${archivoPwd}