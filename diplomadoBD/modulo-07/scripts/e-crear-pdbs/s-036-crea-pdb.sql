--@Author: Johan Axel Zarazua Ramirez
--@Date: 17/02/2023
--@Desc: Crea pdb tipo refreshable

spool ./../../spools/m07-e03-06.txt replace

Prompt Creando PDB tipo refreshable
Prompt Iniciando jzrdip03
!sh s-030-start-cdb.sh jzrdip03 system3

Prompt Iniciando jzrdip04
!sh s-030-start-cdb.sh jzrdip04 system4

Prompt Conectando jzrdip03
connect sys/system3@jzrdip03 as sysdba

Prompt Abriendo jzrdip03_s1
alter pluggable database jzrdip03_s1 open read write;

Prompt Creando tablespace para guardar datos de prueba
alter session set container = jzrdip03_s1;
create tablespace test_refresh_ts
  datafile '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s1/test_refresh.dbf'
  size 1M autoextend on next 1M;

Prompt Creando un usuario común
alter session set container = cdb$root;
create user c##johan_remote identified by johan container = all;
grant create session, create pluggable database to c##johan_remote container = all;

Prompt Conectando a jzrdip04 para crear la liga
connect sys/system4@jzrdip04 as sysdba

Prompt Crear liga
create database link clone_link
  connect to c##johan_remote identified by johan
  using 'JZRDIP03_S1';

Prompt Creando PDB tipo refreshable
create pluggable database jzrdip04_r3
from jzrdip03_s1@clone_link
file_name_convert=(
  '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s1',
  '/u01/app/oracle/oradata/JZRDIP04/jzrdip04_r3'
) refresh mode manual;

Prompt Consultando el último refresh
select last_refresh_scn
from dba_pdbs
where pdb_name='JZRDIP04_R3';

Pause Analizar el valor del scn [enter]

Prompt  Crear tabla y registro en jzrdip03_s1
connect sys/system3@jzrdip03_s1 as sysdba

Prompt Creando usuario de prueba
create user johan_refresh identified by johan
  default tablespace test_refresh_ts
  quota unlimited on test_refresh_ts;

grant create session, create table to johan_refresh;

Prompt Creando tabla test_refresh
create table johan_refresh.test_refresh(id number);

Prompt Insertando datos de prueba
insert into johan_refresh.test_refresh values(1);
commit;

Pause Revisar tabla y datos creados [enter]

Prompt Conectando a la PDB jzrdip04_r3
connect sys/system4@jzrdip04_r3 as sysdba

Prompt Hacer switch a jzrdip04_r3
alter pluggable database jzrdip04_r3 open read only;

alter session set container = jzrdip04_r3;

Prompt Verificando datos
Pause ¿Qué sucedería al intentar consultart la tabla? [enter]
--Se espera error porque no hemos hecho refresh! (es manual)
select * from johan_refresh.test_refresh;

Prompt Hacer refresh desde root
alter session set container = cdb$root;
--la pdb debe estar cerrada para hacer refresh
alter pluggable database jzrdip04_r3 close immediate;
alter pluggable database jzrdip04_r3 refresh;
alter pluggable database jzrdip04_r3 open read only;

Prompt Consultando datos nuevamente
alter session set container = jzrdip04_r3;
Pause ¿Qué se esperaría? [enter]
select * from johan_refresh.test_refresh;

Prompt Mostrando el último scn
select last_refresh_scn
from dba_pdbs
where pdb_name='JZRDIP04_R3';

Pause Analizar resultados [enter]
alter session set container = cdb$root;
alter pluggable database jzrdip04_r3 close immediate;
drop pluggable database jzrdip04_r3 including datafiles;
drop database link clone_link;

connect sys/system4@jzrdip04 as sysdba
drop database link clone_link;

--eliminar usuario común
connect sys/system3@jzrdip03 as sysdba
drop user c##johan_remote cascade;

--eliminar tablespace
alter session set container=jzrdip03_s1;
drop tablespace test_refresh_ts including contents and datafiles;

--eliminar al usuario johan_refresh
drop user johan_refresh cascade;

prompt eliminando archivo en jzrdip04_r3
!sudo rm /u01/app/oracle/oradata/JZRDIP04/jzrdip04_r3/test_refresh.dbf
spool off