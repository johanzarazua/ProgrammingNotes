--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 21/10/2022
--@Descripción: aplicacion de los diferentes modos del shutdown.

define syslogon='sys/system2 as sysdba'

prompt conectando como sys
connect &syslogon

prompt validando existencia de usuario
declare
  v_count number;
begin
  select count(*) into v_count from dba_users where username = 'USER01';

  if v_count > 0 then
    execute immediate 'drop user user01 cascade';
  end if;
end;
/

prompt creando usuario y asignando privilegios
create user user01 identified by user01 quota unlimited on users;
grant create session, create table to user01;

col username format a10
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

pause ejecutar los 4 escripts (a,b,c,d) cada uno en una terminal [enter para continuar]
prompt mostrando los datos de las sesiones
select s.sid, s.serial#, s.username, s.logon_time, t.xid, t.start_date
  from v$session s 
    left join v$transaction t on s.saddr =  t.ses_addr
  where username is not null;

prompt
prompt haciendo shutdown abort
shutdown abort

pause Que sucedio en las terminales? [Enter] para inicar la instancia

prompt
prompt inciando la instancia
startup

pause ejecutar los 4 escripts (a,b,c,d) cada uno en una terminal [enter para continuar]
prompt mostrando los datos de las sesiones
select s.sid, s.serial#, s.username, s.logon_time, t.xid, t.start_date
  from v$session s 
    left join v$transaction t on s.saddr =  t.ses_addr
  where username is not null;

prompt
prompt haciendo shutdown immediate
shutdown immediate

pause Que sucedio en las terminales? [Enter] para inicar la instancia

prompt
prompt inciando la instancia
startup

pause ejecutar los 4 escripts (a,b,c,d) cada uno en una terminal [enter para continuar]
prompt mostrando los datos de las sesiones
select s.sid, s.serial#, s.username, s.logon_time, t.xid, t.start_date
  from v$session s 
    left join v$transaction t on s.saddr =  t.ses_addr
  where username is not null;

prompt
prompt haciendo shutdown transactional
prompt Que cambios se tendrian que hacer oara que shutdown transactional termine?
shutdown transactional

pause Que sucedio en las terminales? [Enter] para inicar la instancia

prompt
prompt inciando la instancia
startup

pause ejecutar los 4 escripts (a,b,c,d) cada uno en una terminal [enter para continuar]
prompt mostrando los datos de las sesiones
select s.sid, s.serial#, s.username, s.logon_time, t.xid, t.start_date
  from v$session s 
    left join v$transaction t on s.saddr =  t.ses_addr
  where username is not null;

prompt
prompt haciendo shutdown normal
prompt Que cambios se tendrian que hacer oara que shutdown normal termine?
shutdown normal

pause Que sucedio en las terminales? [Enter] para inicar la instancia

prompt
prompt inciando la instancia
startup


prompt realizando limpieza
drop user user01 cascade;

prompt listo!!
exit