--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 11/02/2023
--@Descripción: Clonacion de una pdb usando DB Link

spool ./../../spools/m07-e03-04.txt replace

prompt Inciando JZRDIP03
!sh s-030-start-cdb.sh jzrdip03 system3

prompt Inciando JZRDIP04
!sh s-030-start-cdb.sh jzrdip04 system4

prompt conectando a JZRDIP03
connect sys/system3@jzrdip03 as sysdba

--crear usuario en comun a nivel cdb para realizar conexiones mediante DB Link
prompt creando usuario en JZRDIP03
create user c##johan_remote identified by johan container=ALL;
grant create session, create pluggable database to c##johan_remote container=all;

prompt abriendo pdb
alter pluggable database jzrdip03_s1 open read write;

prompt conectando a JZRDIP04 para crear db link
connect sys/system4@jzrdip04 as sysdba

create database link clone_link 
  connect to c##johan_remote identified by johan
  using 'JZRDIP03';

prompt creando PDB jzrdip04_m3
create pluggable database jzrdip04_m3 
  from jzrdip03_s1@clone_link
  file_name_convert=(
    '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s1',
    '/u01/app/oracle/oradata/JZRDIP04/jzrdip04_m3'
  );

prompt Abriendo y verificando PDBS
alter pluggable database jzrdip04_m3 open read write;
show pdbs

pause Analizar resultado [Enter] para continuar con la lmipieza

prompt borrando PDB
alter pluggable database jzrdip04_m3 close;
drop pluggable database jzrdip04_m3 including datafiles;

prompt borrando liga
drop database link clone_link;

prompt borrando usuario, cambiando a JZRDIP03
connect sys/system3@jzrdip03 as sysdba
drop user c##johan_remote cascade;

spool off
exit