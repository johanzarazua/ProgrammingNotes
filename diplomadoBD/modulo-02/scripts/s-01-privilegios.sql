--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 09/septiembre/2022 
--@Descripción: Administración de system privileges


Prompt Conectando como sysdba (sys)
connect sys/system1 as sysdba

Prompt Creando usuario
create user johan01 identified by johan01 quota unlimited on users;

Prompt asignando privilegios
grant create table, create session to johan01;

Prompt Conectando como johan01
connect johan01/johan01

Prompt Creando tabla prueba...
create table test01(
  id number
);

Prompt Conectando como sys
connect sys/system1 as sysdba

col grantee format A30

Prompt mostrando privilegios del usuario
select grantee,privilege,admin_option from dba_sys_privs
  where grantee='JOHAN01';

Prompt haciendo limpieza
drop user johan01 cascade;