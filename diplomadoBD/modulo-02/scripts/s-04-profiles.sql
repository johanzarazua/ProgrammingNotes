--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 09/septiembre/2022 
--@Descripción: Creación de un user profile 

define syslogon = 'sys/system1 as sysdba'

Prompt conectando como sysdba
connect &syslogon

Prompt creando profile
create profile session_limit_profile limit
  sessions_per_user 2
;

Prompt creando usuario user01
create user user01 identified by user01 profile session_limit_profile;
grant create session to user01;

pause abrir 3 terminales y validar el user profile [enter] para continuar, no cerrarlas.

prompt consultando sesiones del usuario user01
col username format a30
col schemaname format a30
select sid, serial#, username, schemaname, status
  from v$session
 where username = 'USER01';

pause [enter] para realizar limpieza
drop user user01;
drop profile session_limit_profile;