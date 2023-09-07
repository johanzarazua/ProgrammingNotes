# --@Autor: Johan Axel Zarazua Ramirez 
# --@Fecha creación: 23/septiembre/2022 
# --@Descripción: Creacion del PFILE para una nueva instancia 
#!/bin/bash

echo "Creando pfile"

export ORACLE_SID="jzrdip02"

echo "Creando archivo de parametros basico"
echo \
  "
    db_name='${ORACLE_SID}'
    memory_target=768M
    control_files=(
      /unam-diplomado-bd/disk-01/app/oracle/oradata/${ORACLE_SID^^}/control01.ctl,
      /unam-diplomado-bd/disk-02/app/oracle/oradata/${ORACLE_SID^^}/control02.ctl,
      /unam-diplomado-bd/disk-03/app/oracle/oradata/${ORACLE_SID^^}/control03.ctl
    )
  " > ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora

echo "Cropobando existencia"

ls -l ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora

echo "Mostrando contenido"
cat ${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora