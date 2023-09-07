--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 17/septiembre/2022 
--@Descripción: Creacion de usuarios, administracion de roles, privilegios y profiles

connect sys/system1 as sysdba

Prompt Creacion de usuario jzr01 con quota y password expire
create user jzr01 identified by jzr01 
  quota 1G on users
  password expire;

Prompt Creación de rol app_role y asignacion de privilegios.
create role app_role;
grant create session, create table, create procedure, create sequence to app_role;

Prompt Asignacion del rol a usaurio jzr01
grant app_role to jzr01;

Prompt conectando como jzr01
connect jzr01/jzr01 

Prompt creando tabla amigo e insertando registro
create table amigo(
  id number(10,0),
  nombre varchar2(100)
);
insert into amigo (id, nombre) values (1, 'Chuy');
commit;

Prompt conectando como sysdba
connect sys/system1 as sysdba

Prompt creando usuario jzr_worker01 con privilegio para crear sesiones
grant create session to jzr_worker01 identified by jzr_worker01;

Prompt creando profile
create profile worker_profile limit
  sessions_per_user 1
  connect_time 1;

Prompt asignando profile a jzr_worker01
alter user jzr_worker01 profile worker_profile;

Prompt otorgando privilegios de insercion en jzr01.amigo
grant insert on jzr01.amigo to jzr_worker01;

Prompt conectando como jzr_worker01
connect jzr_worker01/jzr_worker01

Prompt insercion de 3 registros en amigo
insert into jzr01.amigo (id, nombre) values (2, 'Dany');
insert into jzr01.amigo (id, nombre) values (3, 'Edu');
insert into jzr01.amigo (id, nombre) values (4, 'Eli');
commit;

Prompt pausa de 70 segundos 
exec dbms_session.sleep(70);

Prompt prueba de isnercion despues de 70 segundos
insert into jzr01.amigo (id, nombre) values (5, 'Emi');

Prompt conectando como sysdba
connect sys/system1 as sysdba

col nombre format a30
Prompt comprobando registros en amigo
select * from jzr01.amigo;

Prompt otorgando privilegios a jzr_slave
grant create session to jzr_slave identified by jzr_slave;
grant delete on jzr01.amigo to jzr_slave with grant option ;

Prompt conectando como jzr_slave
connect jzr_slave/jzr_slave

prompt dando privilegios para eliminar registrso en amigo a jzr_worker01
grant delete on jzr01.amigo to jzr_worker01;

Prompt conectando como jzr_worker01
connect jzr_worker01/jzr_worker01

prompt borrando registro de la tabla amigo
delete from jzr01.amigo;


Prompt conectando como sysdba
connect sys/system1 as sysdba

col nombre format a30
Prompt comprobando registros en amigo
select * from jzr01.amigo;

prompt realizando limieza
drop user jzr01 cascade;
drop user jzr_worker01;
drop user jzr_slave;
drop role app_role;
drop profile worker_profile;

exit