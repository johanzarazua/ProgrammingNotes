--@Author: Johan Axel Zarazua Ramirez
--@Date: 17/02/2023
--@Desc: Crea pdb tipo proxy
spool ./../../spools/m07-e03-07.txt replace

Prompt Creando proxy PDB
Prompt Iniciando jzrdip03
!sh s-030-start-cdb.sh jzrdip03 system3

Prompt Iniciando jzrdip04
!sh s-030-start-cdb.sh jzrdip04 system4

connect sys/system3@jzrdip03 as sysdba

Prompt Creando un usuario común
create user c##johan_remote identified by johan container=all;
grant create session, create pluggable database to c##johan_remote
  container=all;

Prompt Abriendo pdb
alter pluggable database jzrdip03_s2 open read write;

alter session set container=jzrdip03_s2;

Prompt Creando tablespace para guardar datos de prueba
create tablespace test_proxy_ts
  datafile '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s2/test_proxy.dbf'
  size 1M autoextend on next 1M;


Prompt Creando usuario de prueba
create user johan_proxy identified by johan
  default tablespace test_proxy_ts
  quota unlimited on test_proxy_ts;

grant create session, create table to johan_proxy;

Prompt Creando tabla test_proxy
create table johan_proxy.test_proxy(id number);

Prompt Insertando datos de prueba
insert into johan_proxy.test_proxy values(1);
commit;

select * from johan_proxy.test_proxy;

Pause Revisar datos [enter]
Prompt COnectando a jzrdip04 para crear liga y proxy pdb
connect sys/system4@jzrdip04 as sysdba

create database link clone_link
  connect to c##johan_remote identified by johan
  using 'JZRDIP03_S2';

Prompt Creando proxy pdb
create pluggable database jzrdip04_p1 as proxy
from jzrdip03_s2@clone_link
file_name_convert=(
  '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s2',
  '/u01/app/oracle/oradata/JZRDIP04/jzrdip04_p1'
);

Pause Abrir la proxy pdb [enter]
alter pluggable database jzrdip04_p1 open read write;
Prompt accediendo a jzrdip03_s2 a través de ka proxy 
connect johan_proxy/johan@jzrdip04_p1

Prompt Mostrabdo datos desde proxy
select * from johan_proxy.test_proxy;

Prompt Insertando desde proxy
insert into johan_proxy.test_proxy values(2);
commit;

Prompt Validando en jzrdip03_s2
connect sys/system3@jzrdip03_s2 as sysdba

select * from johan_proxy.test_proxy;

Pause Analizar resultados [enter]
alter session set container=cdb$root;
drop user c##johan_remote cascade;

--eliminar tablespace
alter session set container=jzrdip03_s2;
drop tablespace test_proxy_ts including contents and datafiles;

--eliminar al usuario
drop user johan_proxy cascade;

Prompt LImpieza en jzrdip04
connect sys/system4@jzrdip04 as sysdba

alter pluggable database jzrdip04_p1 close immediate;
drop pluggable database jzrdip04_p1 including datafiles;

drop database link clone_link;

spool off
exit