--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 04/11/2022
--@Descripción: Adminstracion de las areas de memoria.

connect sys/system2 as sysdba

/*
Consultas obtenidas en el s-17

	ID FECHA	       TOTAL_SGA_1 TOTAL_SGA_2 TOTAL_SGA_3   SGA_FREE  PGA_PARAM PGA_TOTAL_2 PGA_RESERVADA PGA_RESERVADA_MAX PGA_EN_USO  PGA_LIBRE PGA_AUTO_W_AREAS PGA_MANUAL_W_AREAS LOG_BUFFER DB_BUFFER_CACHE SHARED_POOL LARGE_POOL  JAVA_POOL STREAM_POOL
---------- ------------------- ----------- ----------- ----------- ---------- ---------- ----------- ------------- ----------------- ---------- ---------- ---------------- ------------------ ---------- --------------- ----------- ---------- ---------- -----------
  INMEMORY
----------
	 1 04/11/2022 18:29:01	    499.99	499.99	    499.99	  268	     268	 268	    182.29	      356.07	 131.33      33.06		  0		     0	      7.5	      124	  252	       4	  4	      0
       100

	21 04/11/2022 19:28:36	    499.99	499.99	    499.99	  268	     268	 268	    274.65	      356.07	 213.06      32.56		  0		     0	      7.5	      124	  252	       4	  4	      0
       100





*/

prompt configurando administracion Automatic shared memory management (semimanual)
alter system set memory_target=0 scope=spfile;

-- sga = total_sga + inmemory
alter system set sga_target=600M scope=spfile;

-- pga = max_reservada_pga
alter system set pga_aggregate_target=356M scope=spfile;

alter system set shared_pool_size=0 scope=spfile;
alter system set large_pool_size=0 scope=spfile;
alter system set java_pool_size=0 scope=spfile;
alter system set db_cache_size=0 scope=spfile;
alter system set streams_pool_size=0 scope=spfile;

prompt reiniciando instancia para probar modo semi-automatico
pause [Enter] para reiniciar
shutdown immediate
startup

Prompt mostrando parametros modo semi-automatico
select (
  select value/1024/1024 from v$spparameter where name='memory_target'
) memory_target, (
  select value/1024/1024 from v$spparameter where name='memory_max_target'
) memory_max_target, (
  select value/1024/1024 from v$spparameter where name='sga_target'
) sga_target, (
  select value/1024/1024 from v$spparameter where name='pga_aggregate_target'
) pga_aggregate_target, (
  select value/1024/1024 from v$spparameter where name='shared_pool_size'
) shared_pool_size, (
  select value/1024/1024 from v$spparameter where name='large_pool_size'
) large_pool_size, (
  select value/1024/1024 from v$spparameter where name='java_pool_size'
) java_pool_size, (
  select value/1024/1024 from v$spparameter where name='db_cache_size'
) db_cache_size, (
  select value/1024/1024 from v$spparameter where name='streams_pool_size'
) streams_pool_size
from dual;

prompt agregando nuevo registro a la tabla de valores de memoria
@s-14-monitor-mem.sql

pause Analizar resultados, [enter] para continuar

prompt Realizando configuracion Manual shared memory management
alter system set memory_target=0 scope=spfile;
alter system set sga_target=0 scope=spfile;

-- se mantiene la configuracion para la pga
alter system set pga_aggregate_target=356M scope=spfile;

-- areas internas de la sga
alter system set shared_pool_size=252M scope=spfile;
alter system set large_pool_size=4M scope=spfile;
alter system set java_pool_size=4M scope=spfile;
alter system set db_cache_size=124M scope=spfile;
alter system set streams_pool_size=0 scope=spfile;

prompt reiniciando instancia para probar modo manual
pause [Enter] para reiniciar
shutdown immediate
startup

Prompt mostrando parametros modo manual Shared Memory Management
select (
  select value/1024/1024 from v$spparameter where name='memory_target'
) memory_target, (
  select value/1024/1024 from v$spparameter where name='memory_max_target'
) memory_max_target, (
  select value/1024/1024 from v$spparameter where name='sga_target'
) sga_target, (
  select value/1024/1024 from v$spparameter where name='pga_aggregate_target'
) pga_aggregate_target, (
  select value/1024/1024 from v$spparameter where name='shared_pool_size'
) shared_pool_size, (
  select value/1024/1024 from v$spparameter where name='large_pool_size'
) large_pool_size, (
  select value/1024/1024 from v$spparameter where name='java_pool_size'
) java_pool_size, (
  select value/1024/1024 from v$spparameter where name='db_cache_size'
) db_cache_size, (
  select value/1024/1024 from v$spparameter where name='streams_pool_size'
) streams_pool_size
from dual;

prompt agregando nuevo registro a la tabla de valores de memoria
@s-14-monitor-mem.sql

pause Analizar resultados, [enter] para continuar

prompt restaurando modo automatico
alter system set memory_target=768M scope=spfile;

prompt reseteando parametros
alter system reset sga_target scope=spfile;
alter system reset pga_aggregate_target scope=spfile;

-- areas internas de la sga
alter system reset shared_pool_size scope=spfile;
alter system reset large_pool_size scope=spfile;
alter system reset java_pool_size scope=spfile;
alter system reset db_cache_size scope=spfile;
alter system reset streams_pool_size scope=spfile;

prompt reiniciando instancia para probar modo automatico
pause [Enter] para reiniciar
shutdown immediate
startup

Prompt mostrando parametros modo Automatic Shared Memory Management
select (
  select value/1024/1024 from v$spparameter where name='memory_target'
) memory_target, (
  select value/1024/1024 from v$spparameter where name='memory_max_target'
) memory_max_target, (
  select value/1024/1024 from v$spparameter where name='sga_target'
) sga_target, (
  select value/1024/1024 from v$spparameter where name='pga_aggregate_target'
) pga_aggregate_target, (
  select value/1024/1024 from v$spparameter where name='shared_pool_size'
) shared_pool_size, (
  select value/1024/1024 from v$spparameter where name='large_pool_size'
) large_pool_size, (
  select value/1024/1024 from v$spparameter where name='java_pool_size'
) java_pool_size, (
  select value/1024/1024 from v$spparameter where name='db_cache_size'
) db_cache_size, (
  select value/1024/1024 from v$spparameter where name='streams_pool_size'
) streams_pool_size
from dual;

prompt agregando nuevo registro a la tabla de valores de memoria
@s-14-monitor-mem.sql

pause Analizar resultados, [enter] para continuar