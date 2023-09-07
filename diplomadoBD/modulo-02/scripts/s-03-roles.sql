--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 09/septiembre/2022 
--@Descripción: Administración de roles

Prompt Conectando como sys 
connect sys/system1 as sysdba

Prompt creando roles
create role web_admin_role;
create role web_root_role;

Prompt asignando privilegios a web_admin_role
grant create session, create table, create sequence to web_admin_role;

Prompt asignando los privilegios de web_admin_role a web_root_role
grant web_admin_role to web_root_role;

Prompt creando al usuario j_admin 
create user j_admin identified by j_admin;
Prompt otorgando rol
grant web_admin_role to j_admin with admin option;

Prompt conectando como j_admin
pause ¿Sera posible conectarse como j_admin?
connect j_admin/j_admin


Prompt creando usuario j_os_admin
connect sys/system1 as sysdba 
create user j_os_admin identified by j_os_admin;

Prompt dando el rol web_admin_role con j_admin a j_os_admin
connect j_admin/j_admin
grant web_admin_role to j_os_admin;


Prompt verificando privilegios de j_os_admin
connect sys/system1 as sysdba

col grantee format a20
col granted_role format a30
select grantee, granted_role, admin_option 
from dba_role_privs
where grantee = 'J_OS_ADMIN';


drop user j_admin;
drop user j_os_admin;
drop role web_admin_role;
drop role web_root_role;