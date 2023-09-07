--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 04/11/2022
--@Descripción: Configuraciones para suspender una BD

prompt conectando como sys
connect sys/system2 as sysdba

prompt creando usuarios
create user user03_s1 identified by user03_s1 quota unlimited on users;
grant create session, create table to user03_s1;

pause [Enter] para reiniciar instancia
shutdown immediate
startup

prompt abrir terminal t1, entrar como user03_s1
pause [Enter] al terninar

prompt suspendiendo instancia.
pause Que sucedera considerando que hay una sesion en T1? [enter] para continuar
alter system suspend;
-- todo funciona bien 

prompt salir de sesion en T1, intentar auntenticar nuevamente y crear una nueva tabla
pause Que sucedera? considerar que la BD esta suspendida [Enter] para continuar
-- permitira acceder porque sus datos estan cargados en cache, pero al crear tabla se quedara en espera

prompt mostrando status de suspension
select database_status from v$instance;

prompt termianndo suspension
pause Que sucedera? considerando que en T1 hay una sesion (posiblemente) [Enter] para continuar 
-- se quita la suspencion y en la terminal donde se creo una tabla se desbloquea y realiza su operacion
alter system resume;

prompt mostrando status de suspension
select database_status from v$instance;

prompt Limpieza, salir de sesion en T1 de ser necesario
pause [Enter] para continuar
drop user user03_s1 cascade;