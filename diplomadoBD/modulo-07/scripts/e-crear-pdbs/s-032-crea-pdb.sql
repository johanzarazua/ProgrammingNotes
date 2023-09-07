--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 10/02/2023
--@Descripción: Creacion de una PDB a partir de SEED cláusula file_name_convert

spool ./../../spools/m07-e03-02.txt replace

Prompt creando PDB con rutas particulares
Prompt conectar a root
conn sys/system3@jzrdip03 as sysdba

Prompt creando PDB jzrdip03_s3
create pluggable database jzrdip03_s3 admin user admin_s3 identified by admin_s3
  file_name_convert=(
    '/u01/app/oracle/oradata/JZRDIP03/pdbseed',
    '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s3'
  );


/*
Otra opción es configurar el parámetro PDB_FILE_NAME_CONVERT
alter system set pdb_file_name_convert=
  '/u01/app/oracle/oradata/JZRDIP03/pdbseed',
  '/u01/app/oracle/oradata/JZRDIP03/jzrdip03 s3';

Para crear la PDB:
create pluggable database jzrdip03 s3 admin user admin s3 identified by admin_s3;
*/
pause Revisar datafiles generados en ORACLE_BASE/oradata [enter] para continuar
Prompt Limpieza
drop pluggable database jzrdip03_s3 including datafiles;

spool off
exit