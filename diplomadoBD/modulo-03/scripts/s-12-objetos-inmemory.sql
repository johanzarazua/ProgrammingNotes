--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 29/10/2022
--@Descripción: Creacion de objetos en IM column store 

Prompt AUtenticando como sysdba
connect sys/system2 as sysdba

Prompt Consultando datos de user03imc.movie
col title format a50
select title, trunc(duration/60,1) duration_hr
from user03imc.movie
where upper(title) like '% WAR %';

Prompt Mostrando plan de ejecución
explain plan
set statement_id='q1' for
select  /*+gather_plan_statistics */  title, trunc(duration/60,1) duration_hr
from user03imc.movie
where upper(title) like '% WAR %';

Prompt Mostrando el plan de ejecución
select * from table
(
  dbms_xplan.display(
    statement_id => 'q1'
  )
);
Pause Analizar resultados [ENTER] para continuar

Prompt Habilitando in memory column store para la tabla movie
alter table user03imc.movie inmemory;

Prompt Mostrando configuración IM Column store
col table_name format a30
select table_name, inmemory,inmemory_compression,inmemory_priority
from dba_tables
where table_name='MOVIE'
and owner = 'USER03IMC';

Pause Analizqar el plan de ejecucion [Enter]
Prompt Consultando segmentos de la tabla movie en el IM column store
select 
  segment_name,
  bytes/1024/1024 mbs,
  inmemory_size/1024/1024 inmemory_size_mb,
  populate_status
from v$im_segments
where 
  segment_name='MOVIE' and 
  owner = 'USER03IMC';

pause Analizar resultados [Enter] para continuar

prompt realizando consulta en la tabla de MOVIE para provocar carga de datos en el IM Colum Store
select title, trunc(duration/60,1) duration_hr
from user03imc.movie
where upper(title) like '% WAR %';

pause Cuantos registros se obtuvieron? [Enter] para continuar

Prompt Consultando segmentos de la tabla movie en el IM column store
col segment_name format a30 
select 
  segment_name,
  bytes/1024/1024 mbs,
  inmemory_size/1024/1024 inmemory_size_mb,
  populate_status
from v$im_segments
where 
  segment_name='MOVIE' and 
  owner = 'USER03IMC'
;

pause Analizar resultados [Enter] para continuar

prompt mostrando informacion de los IMCUs 
col column_name format a20
col minimum_value format a20
col maximum_value format a50
select
  column_number,
  column_name,
  minimum_value,
  maximum_value
from
  v$im_col_cu cu, 
  dba_objects o, 
  dba_tab_cols c
where
  cu.objd = o.data_object_id and
  o.object_name = c.table_name and
  cu.column_number = c.column_id and
  o.object_name = 'MOVIE' and o.owner = 'USER03IMC'
order by 1,3
;

pause Analizar resultados [Enter] para continuar

prompt Deshabilitando el uso de la IM C store y sus IMCUs
alter session set inmemory_query = disable;

prompt ejecutando consulta nuevamente
select title, trunc(duration/60,1) duration_hr
from user03imc.movie
where upper(title) like '% WAR %';

prompt mostrando estadisticas de la IM C store y sus IMCUS - inmemory_query = disable
col display_name format a30
select display_name,value
from v$mystat m, v$statname n
where m.statistic# = n.statistic#
and display_name in (
  'IM scan segments minmax eligible',
  'IM scan CUs delta pruned',
  'IM scan segments disk',
  'IM scan bytes in-memory',
  'IM scan bytes uncompressed',
  'IM scan rows',
  'IM scan blocks cache'
);

pause Analizar resultados, [Enter] para continuar

prompt habilitar nuevamente el uso de la IM C store
alter session set inmemory_query = enable;

prompt ejecuntando consulta nuevmente 
select title, trunc(duration/60,1) duration_hr
from user03imc.movie
where upper(title) like '% WAR %';

prompt mostrando estadisticas de la IM C store y sus IMCUS - inmemory_query = enable
col display_name format a30
select display_name,value
from v$mystat m, v$statname n
where m.statistic# = n.statistic#
and display_name in (
  'IM scan segments minmax eligible',
  'IM scan CUs delta pruned',
  'IM scan segments disk',
  'IM scan bytes in-memory',
  'IM scan bytes uncompressed',
  'IM scan rows',
  'IM scan blocks cache'
);

pause Analizar resultados, [Enter] para continuar

Prompt Mostrando nuvamente el plan de ejecución con IM C store habilitada
explain plan
set statement_id='q2' for
select /*+gather_plan_statistics */ title, trunc(duration/60,1) duration_hr
from user03imc.movie
where upper(title) like '% WAR %';

Prompt Mostrando el plan de ejecución
select * from table
(
  dbms_xplan.display(
    statement_id => 'q2'
  )
);

Pause Analizar el plan de ejecucion [ENTER] para continuar

prompt deshabilitar el uso del IM C para hacer el script idempotente
alter table user03imc.movie no inmemory;

disconnect