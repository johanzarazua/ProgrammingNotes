--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 10/septiembre/2022 
--@Descripción: Archivo de passwords

define syslogon='sys/admin1234# as sysdba'

prompt conectando como sysdba
connect &syslogon

prompt consultando archivo de passwords antes de agregar usuarios, se espera sys y system
col username format a20
col account_status format a20
col last_login format a40
select username,sysdba,sysoper,sysasm,sysbackup,sysdg,syskm,account_status,last_login 
from v$pwfile_users;

pause [enter para continuar]

Prompt asignandp privilegios de admon
grant sysdba to user01;
grant sysoper to user02;
grant sysbackup to user03;

prompt consultando nuevamente
select username,sysdba,sysoper,sysasm,sysbackup,sysdg,syskm,account_status,last_login 
from v$pwfile_users;

prompt actualizar password de sys y system
alter user sys identified by system1;
alter user system identified by system1;

prompt realizando limpieza
drop user user01;
drop user user02;
drop user user03;