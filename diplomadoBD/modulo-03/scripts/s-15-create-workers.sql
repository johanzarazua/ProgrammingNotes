--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 04/11/2022
--@Descripción: Creacion de usarios workers

prompt conectando como sysdba
connect sys/system2 as sysdba

set serveroutput on
prompt creando usuarios.
declare
  v_num_users number := 3;
  v_user_prefix varchar2(20) := 'WORKER_M03_';
  v_username varchar2(20);

  cursor cur_usuarios is 
    select username from all_users where username like v_user_prefix||'%';

begin
  
  -- realizando limpieza de usuarios.
  for r in cur_usuarios loop
    execute immediate 'drop user '||r.username||' cascade';
  end loop;

  -- creando workers
  for i in 1..v_num_users loop
    v_username := v_user_prefix||i;
    dbms_output.put_line('creando worker ' || v_username);
    execute immediate 
      'create user ' || v_username || ' identified by ' || v_username || ' quota unlimited on users';
    
    execute immediate 
      'grant create session, create table, create job, create procedure, create sequence to ' || v_username;
  end loop;

end;
/

prompt invocando la creacion de objetos para cada worker


define p_user = WORKER_M03_1
@s-16-create-worker-objects.sql
-- para parametros se hace lo siguiente
-- @s-16-create-worker-objects.sql WORKER_M03_1

define p_user = WORKER_M03_2
@s-16-create-worker-objects.sql

define p_user = WORKER_M03_3
@s-16-create-worker-objects.sql