--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 12/11/2022
--@Descripción: visualizacion de conexiones y sesiones

prompt conectando como sysdba
connect sys/system2 as sysdba 

prompt creando user04
create user user04 identified by user04 quota unlimited on  users;
grant create table, create session to user04;

pause Iniciar sesion en T2 como user04 [Enter] para continuar

prompt mostranndo datos de las sesiones de user04
col username format a30
select username, sid, serial#, server, paddr, status
from v$session
where username = 'USER04';

pause Analizar resultados, [Enter] para continuar
-- Se espera solo un registro, por T2

prompt Configurando el rol plustrace
@?/sqlplus/admin/plustrce.sql

grant plustrace to user04;

prompt En T2, cerrar sesion, volver a iniciar y hbailitar autotrace
pause [Enter] al terminar

prompt mostrando nuevamente las sesiones de user04
pause Que se obtendra? [Enter] para continuar
-- se deberi aver, la sesion del usaurio y la que se crea por autotrace
select username, sid, serial#, server, paddr, status
from v$session
where username = 'USER04';

pause Analizar resultados [Enter] para continuar

prompt en T2, cerrar sesion de user04, manteniendo conexion (disconnect)
pause [Enter] al terminar

prompt mostrando nuevamente las sesiones de user04, ya no debe existir la sesion de user04
select username, sid, serial#, server, paddr, status
from v$session
where username = 'USER04';

pause Analizar resultados [Enter] para continuar

prompt mostrando los datos del server process que en teoria debe existir.
prompt Indicar el valor address del proceso que se muestra en la sesion de user04
select sosid, username, program from v$process
  where addr = hextoraw('&p_addr');

pause Analizar resultados, [Enter] para continuar

prompt mostrando datos del proceso a nivel de s.o.
prompt observar la consulta anterior y proporcionar el valor del id del proceso a nivel de s.o. (sosid)
!ps -ef | grep -e &p_sosid | grep -v grep

pause [Enter] para realizar limpieza
drop user user04 cascade;

prompt Listo!!!
exit