--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 21/01/2023
--@Descripción: Uso de Flashback drop

define userlogon='user06/user06'

spool ./../spools/e-06.txt replace

Prompt 1. Conectando como sys
connect sys/system2 as sysdba

Prompt Activando la papelera de reciclaje
alter session set recyclebin=on;

Prompt Vericando contenido de la papelera
col object_name format a30
col original_name fromat a15
select object_name, original_name
  from recyclebin;

Prompt 2. Conectando con el usuario user06
connect &userlogon

Prompt Creando la tabla
create table fb_drop(
  id      number, 
  datos   varchar2(10)
);

Prompt Insertando datos 
insert into fb_drop values(1, 'dato1');
insert into fb_drop values(2, 'dato2');
insert into fb_drop values(3, 'dato3');
insert into fb_drop values(4, 'dato4');
commit;

Prompt Mostrando datos de la tabla
select * from fb_drop;

Prompt 3. Eliminado la tabla
drop table fb_drop;
commit;

Prompt Verificando que se eliminó
select * from fb_drop;

Prompt 4. Mostrando contenido de recyclebin
select object_name, original_name
  from recyclebin;

Prompt 5. Consultando el contenido del object_name
select * from "&object_name";

prompt 6. Recuperando tabla eliminada
flashback table fb_drop to before drop;

prompt Verificando tabla recuperada
select * from fb_drop;

prompt 7. Eliminando tabla nuevamente
drop table fb_drop;
commit;

Prompt Verificando que se eliminó
select * from fb_drop;

Prompt 8 Creando nuevamente la tabla con nuevos datos.

Prompt Creando la tabla
create table fb_drop(
  id      number, 
  datos   varchar2(10)
);

Prompt Insertando datos 
insert into fb_drop values(5, 'dato5');
insert into fb_drop values(6, 'dato6');
insert into fb_drop values(7, 'dato7');
insert into fb_drop values(8, 'dato8');
commit;

Prompt Mostrando datos de la tabla
select * from fb_drop;

Prompt 9. Mostrando contenido de recyclebin
col object_name format a30
col original_name format a15
select object_name, original_name from recyclebin;

prompt 10. Eliminando la tabla nueva
drop table fb_drop;
commit;

Prompt Verificando que se eliminó
select * from fb_drop;

Prompt 11. Mostrando contenido de recyclebin
col object_name format a30
col original_name format a15
select object_name, original_name from recyclebin;


prompt 12. Recuperando ambas tablas y renombrarndolas
prompt fb_drop_1
flashback table "&object_name" to before drop rename to fb_drop_1;

prompt consultando la tabla recuperada
select * from fb_drop_1;

prompt fb_drop_2
flashback table "&object_name" to before drop rename to fb_drop_2;

prompt consultando la tabla recuperada
select * from fb_drop_2;

prompt 13. Deshabilitando papelera
alter session set recyclebin = off;

prompt 14. Eliminando tablas y verifcando su eliminacion
drop table fb_drop_1;
drop table fb_drop_2;
commit;

Prompt Mostrando contenido de recyclebin
col object_name format a30
col original_name format a15
select object_name, original_name from recyclebin;

prompt Listo!!!
exit