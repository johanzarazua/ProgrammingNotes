--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 21/01/2023
--@Descripción: Uso de Flashback database

set verify off
define userlogon='user06/user06'
define syslogon = 'sys/system2 as sysdba'

spool ./../spools/e-07.txt replace

prompt 1. Conectando con sys
conn &syslogon

prompt Verificando SCN actual
select dbms_flashback.get_system_change_number() scn_inicial from dual;

prompt 2. Creando punto de restauracion
create restore point punto_rest;

prompt 3. Consultando la vista de puntos de resturacion
col name format a15
col time format a50
select name, scn, time from v$restore_point;

prompt 4. Conectando con user06
conn &userlogon

prompt creando tabla fb_database
create table fb_database(
  id number
);

prompt insertando datos en fb_database
insert into fb_database values(1);
insert into fb_database values(2);
insert into fb_database values(3);
insert into fb_database values(4);

prompt cosnultando datos en fb_database
select * from fb_database;

prompt 5. Iniciar la instancia en modo mount
conn &syslogon
prompt deteniendo isntancia
shutdown immediate
prompt 
prompt inicnando en modo mount
startup mount;

prompt 6. regresando la base de datos el punto de restauracion
flashback database to restore point punto_rest;

prompt 7. Abrir la base en modo open y reiniciar los redos log
alter database open resetlogs;

prompt 8. Verificar que recupero la base con el pinto de restauracion
select * from user06.fb_database;

prompt 9. Eliminando  punto de restauracion
drop restore point punto_rest;

exit