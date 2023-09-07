--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 10/septiembre/2022 
--@Descripción: Privilegios de administración  

define syslogon = 'sys/system1 as sysdba'

Prompt conectando como sysdba
connect &syslogon

Prompt creando usaurio user01
grant create session, create table to user01 identified by user01;
alter user user01 quota unlimited on users;

grant create session, create table to user02 identified by user02;
alter user user02 quota unlimited on users;

grant create session, create table to user03 identified by user03;
alter user user03 quota unlimited on users;

Prompt otorgando privilegios de administracion
grant sysdba, sysoper to user01;

Prompt conectando con user01
connect user01/user01

Prompt mostrando usuario
show user

Prompt mostrando esquema
select sys_context('USERENV','CURRENT_SCHEMA') as schema from dual;

Prompt mostrando el metodo de autenticacion
select sys_context('USERENV','AUTHENTICATION_METHOD') as schema from dual;

Prompt creando tabla e insertando datos, pertenece a user01
create table test(id number);
insert into test (id) values (1);
commit;


Prompt conectando con user01 as sysdba 
connect user01/user01 as sysdba

Prompt mostrando usuario
show user

Prompt mostrando esquema
select sys_context('USERENV','CURRENT_SCHEMA') as schema from dual;

Prompt mostrando el metodo de autenticacion
select sys_context('USERENV','AUTHENTICATION_METHOD') as schema from dual;

Prompt mostrando tabla test
select * from user01.test;


Prompt conectando con user01 as sysoper
connect user01/user01 as sysoper

Prompt mostrando usuario
show user

Prompt mostrando esquema
select sys_context('USERENV','CURRENT_SCHEMA') as schema from dual;

Prompt mostrando el metodo de autenticacion
select sys_context('USERENV','AUTHENTICATION_METHOD') as schema from dual;

Prompt mostrando tabla test
select * from user01.test;

Prompt otorgando privilegios para que cualquier usuario pueda  leer los datos de la tabla test
connect user01/user01 

grant select on test to public;

prompt conectando como usuario user02
connect user02/user02

prompt consultando tabla publica
--aunque esta en el esquema public, es necesario colocar el esquema del usuario
--ya que esto solo nos permite dar el privilegio de select a todos los usuarios de la BD
select * from user01.test; 


prompt conectando como usuario user02
connect user03/user03

prompt consultando tabla publica
select * from user01.test; 

connect sys/system1 as sysdba
prompt aplicando limpieza
drop user user01 cascade;
drop user user02 cascade;
drop user user03 cascade;