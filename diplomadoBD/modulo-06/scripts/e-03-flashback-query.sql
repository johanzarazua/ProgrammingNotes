--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 20/01/2023
--@Descripción: Uso de flashback query

define syslogon = 'sys/system2 as sysdba'
define eUser = 'user06'
define eUserlogon = 'user06/user06'

spool ./../spools/e-03-flashback-query.txt replace

prompt conectando como sys
conn &syslogon

Prompt 1. Creando al usuario user06
create user &eUser identified by &eUser default tablespace users quota unlimited on users;
grant dba to &eUser;

Prompt 2. Conectandose como user06
conn &eUserlogon
Prompt Crenado la tabla fb_query
create table fb_query(
  id    number(2), 
  name  varchar2(10)
);

Prompt 3. Insertando datos . . .
insert into fb_query(id, name) values(1, 'dato1');
insert into fb_query(id, name) values(2, 'dato2');
insert into fb_query(id, name) values(3, 'dato3');
commit;

Prompt Mostrando datos de la tabla
select * from fb_query;

exec dbms_lock.sleep(5);

Prompt 4. Obteniendo SCN y marca de tiempo
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora1 from dual;
select current_scn scn1 from v$database;

prompt 5. Modificando un dato en la tabla
update fb_query set name = 'cambio1' where id = 1;
commit;
select * from fb_query;

exec dbms_lock.sleep(5);

Prompt 6. Obteniendo SCN y marca de tiempo nuevamente
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora2 from dual;
select current_scn scn2 from v$database;

prompt 7. Eliminando un registro de la tabla
delete from fb_query where id = 1;
commit;
select * from fb_query;

exec dbms_lock.sleep(5);

prompt 8. Obteniendo SCN y marca de tiempo nuevamente
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora3 from dual;
select current_scn scn3 from v$database;

prompt 9. Mostrando informacion de diferentes momentos
--hora 1
select * from fb_query as of timestamp to_timestamp('&fechaHora1', 'dd-mm-yyyy hh24:mi:ss');
--scn 3
select * from fb_query as of scn &scn3;


prompt 10. Recuperando el dato eliminado
--scn 2
insert into fb_query(id, name)
  select * from fb_query as of scn &scn2 where id = 1;

prompt Mostrando informacion recuperada
select * from fb_query;

prompt Listo !!!
exit