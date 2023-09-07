--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 12/11/2022
--@Descripción: configuracion de los distintos modos de conexion

prompt configurando modo compartido
connect sys/system2 as sysdba

prompt  mostrando servicios del listener
--este comando se puede ejecutar con usaurio ordinario, ya que si devuelve salida
!lsnrctl services

prompt configurando dispatcher
-- si se desean configurar diferentes dispatcher se hace uso de coma
alter system set 
  dispatchers = '(ADDRESS=(PROTOCOL=TCP)(PORT=5000))','(ADDRESS=(PROTOCOL=TCP)(PORT=5001))'
  scope = both;

prompt configurando 3 shared servers
alter system set shared_servers = 3 scope = both;

prompt configurando DRCP
prompt habilitando pool existente por defult
exec dbms_connection_pool.start_pool();

prompt configurando pool servers minimos existentes en el pool
-- una palabra de cero caracteres es igual que null (solo en sql)
-- el primer parametro indica el nombre del pool
exec dbms_connection_pool.alter_param ('','MINSIZE','5');

prompt configurando pool servers maximos existentes en el pool
exec dbms_connection_pool.alter_param ('','MAXSIZE','50');

prompt configurando tiempo de vida maximo en el pool
exec dbms_connection_pool.alter_param ('','INACTIVITY_TIMEOUT','36000');

prompt configurando timepo de inactividad en el cliente
exec dbms_connection_pool.alter_param ('','MAX_THINK_TIME','300');

prompt notificando al listener la nueva configuracion
alter system register;

prompt  mostrando servicios del listener nuevamente
!lsnrctl services

pause Analizar resultados [Enter] para continuar

prompt reiniciando instancia
shutdown immediate
startup

alter system register;

prompt revisando servicios del listener despues del reincio
!lsnrctl services

prompt Abrir tnsnames.ora, agregar los tres aliases para las conexiones con los nuevos modos
pause [Enter] al terminar

prompt probando modo dedicado
connect sys/system2@jzrdip02_dedicated as sysdba
select server from v$session where username = 'SYS';

prompt probando modo pool DRCP
connect sys/system2@jzrdip02_pooled as sysdba
select server from v$session where username = 'SYS';

connect sys/system2@jzrdip02_shared as sysdba
select server from v$session where username = 'SYS';

prompt revisando servicios del listener en modo compartido
!lsnrctl services

pause Analizar resultados [Enter] para continuar

prompt mostrando datos de v$circuit
select circuit, dispatcher, status, bytes/1024 kbs from v$circuit;