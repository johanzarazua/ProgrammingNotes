--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 05/11/2022
--@Descripción: Configuraciones para inactivar una BD

connect sys/system2 as sysdba

create user user03_a1 identified by user03_a1 quota unlimited on users;
grant create session, create table to user03_a1;

create user user03_a2 identified by user03_a2 quota unlimited on users;
grant create session, create table to user03_a2;

create user user03_a3 identified by user03_a3 quota unlimited on users;
grant create session, create table to user03_a3;


prompt asignando privilegio sysbackup a user03_a1
grant sysbackup to user03_a1;

prompt Abrir dos terminales, T1 y T2, autenticar en T1 como user03_a1
prompt autenticar en T2 como user03_a2, crear tabla y registros
pause [Enter] al terminar las instrucciones

prompt inactivando la BD ¿Que sucedera? considerando las sesiones en T1 y T2
-- se queda colgado porque se esta creando tabla y registros en T2
pause [Enter] para continuar
alter system quiesce restricted;
prompt BD inactiva

prompt abrir una terminal T3 y autenticar con user03_a3
prompt abrir una terminal T4 e intentar autenticar autenticar con user03_a1 como sysbackup
pause ¿Que sucedera? [Enter] para continuar

prompt mostrando status de inactividad
-- muestra inactivo
select active_state from v$instance;

prompt reactivando instancia 
pause Analizar terminales, comentar que sucedera [Enter] para continuar
alter system unquiesce;

pause Cerrar sesiones para realizar limpieza, [Enter] para continuar
drop user user03_a1 cascade;
drop user user03_a2 cascade;
drop user user03_a3 cascade;