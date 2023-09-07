--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 11/02/2023
--@Descripción: Creacion de pdb a partir de una non CDB

spool ./../../spools/m07-e03-05.txt replace

prompt Inciando JZRDIP03
!sh s-030-stop-cdb.sh jzrdip03 system3

prompt Inciando JZRDIP04
!sh s-030-start-cdb.sh jzrdip04 system4

prompt Inciando JZRDIP04
!sh s-030-start-cdb.sh jzrdip02 system2

prompt creando un usuario Non CDB
connect sys/system2@jzrdip02_dedicated as sysdba
alter system set encryption wallet open identified by "wallet_password";
create user johan_remote identified by johan;
grant create session, create pluggable database to johan_remote;

prompt conectando a JZRDIP04
connect sys/system4@jzrdip04 as sysdba

prompt creando DB Link
create database link clone_link 
  connect to johan_remote identified by johan
  using 'JZRDIP02_DEDICATED';

alter system set encryption wallet open identified by "wallet_password";
prompt creando pdb
create pluggable database jzrdip04_m4  
  from non$cdb@clone_link
  file_name_convert=(
    '/u01/app/oracle/oradata/JZRDIP02',
    '/u01/app/oracle/oradata/JZRDIP04/jzrdip04_m4'
  ) keystore identified by "wallet_password";

prompt abriendo nueva pdb
alter pluggable database jzrdip04_m4 open read write;
show pdbs

pause Analizar resultado [Enter] para realizar limpieza.

prompt borrando PDB
alter pluggable database jzrdip04_m4 close;
drop pluggable database jzrdip04_m4 including datafiles;

prompt borrando liga
drop database link clone_link;

prompt borrando usuario, cambiando a JZRDIP03
connect sys/system2@jzrdip02_dedicated as sysdba
drop user johan_remote cascade;

spool off
exit