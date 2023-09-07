--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 20/01/2023
--@Descripción: Uso de Flashback Version Query

set verify off

define syslogon = 'sys/system2 as sysdba'
define eUserlogon = 'user06/user06'


spool ./../spools/e-04-flashback-version-query.txt replace

prompt Conectando con usuario06
conn &eUserlogon

prompt 1. Creando tabla fb_version
create table fb_version(
  id        number,
  name      varchar2(15),
  fehaHora  varchar2(30)
);

exec dbms_lock.sleep(5);

prompt Insertando registros 
insert into fb_version values(1, 'valor1', to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss'));
insert into fb_version values(2, 'valor2', to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss'));
insert into fb_version values(3, 'valor3', to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss'));
commit;

prompt mostrando datos de la tabla
select * from fb_version;
exec dbms_lock.sleep(5);

prompt 2. Mostrando scn actual
select current_scn scn1 from v$database;

prompt 3. Actualizando un registro de la tabla
update fb_version set 
  name = 'cambio1', fehaHora = to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss')
  where id = 1;
commit;

prompt mostrando datos de la tabla
select * from fb_version;
exec dbms_lock.sleep(5);

prompt 4. Actualizando un registro de la tabla
update fb_version set 
  name = 'cambio2', fehaHora = to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss')
  where id = 2;
commit;

prompt mostrando datos de la tabla
select * from fb_version;
exec dbms_lock.sleep(5);

prompt 5. Eliminando un registro
delete from fb_version where id = 1;
commit;

prompt mostrando datos de la tabla
select * from fb_version;
exec dbms_lock.sleep(5);

prompt 6. Mostrando scn actual
select current_scn scn2 from v$database;

prompt 7. Mostrando el historico de los eventos ocurridos
prompt Consulta 1 (fechaHora)
select id, name, fehaHora from fb_version versions between timestamp minvalue and maxvalue
  where id = 1;

prompt Consulta 1 (scn)
select id, name, fehaHora from fb_version versions between scn &scn1 and &scn2
  where id = 1;