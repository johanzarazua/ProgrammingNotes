--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 10/septiembre/2022 
--@Descripción: Actualizar parámetros

connect sys/system1 as sysdba

prompt realizando respaldo de spfile
create pfile from spfile;

prompt actualizando parametros
prompt Modificando nls_date_format
prompt Nivel sesion, ok
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

prompt nivel memoria, se espera error
alter system set nls_date_format='dd/mm/yyyy hh24:mi:ss' scope=memory;

prompt nivel spfile, ok
alter system set nls_date_format='dd/mm/yyyy hh24:mi:ss' scope=spfile;

prompt nivel spfile y memory, se espera error
alter system set nls_date_format='dd/mm/yyyy hh24:mi:ss' scope=both;


prompt Modificando db_domain
prompt Nivel sesion, se spera error
alter session set db_domain='diplomado.fi.unam.mx';

prompt nivel memoria, se espera error
alter system set db_domain='diplomado.fi.unam.mx' scope=memory;

prompt nivel spfile, ok
alter system set db_domain='diplomado.fi.unam.mx' scope=spfile;

prompt nivel spfile y memory, se espera error
alter system set db_domain='diplomado.fi.unam.mx' scope=both;


prompt Modificando deferred_segment_creation
prompt Nivel sesion, Ok
alter session set deferred_segment_creation=false;

prompt nivel memoria, ok
alter system set deferred_segment_creation=false scope=memory;

prompt nivel spfile y memory, ok
alter system set deferred_segment_creation=false scope=both;

prompt Realizando limpieza
prompt para nls_date_format
alter system reset nls_date_format scope=spfile;

prompt para db_domain
alter system set db_domain='fi.unam' scope=spfile;

prompt para deferred_segment_creation
alter system reset deferred_segment_creation scope=both;


col name format a30
col value format a30
col default_value format a30
Prompt mostrando nuevamente los valores en session/memoria (v$parameter)
select name,isdefault,isses_modifiable, issys_modifiable, value,default_value 
from v$parameter where name in(
  'db_domain','nls_date_format','deferred_segment_creation'
);

Prompt mostrando nuevamente los valores en spfile (v$spparameter)
select name,value 
from v$spparameter where name in(
  'db_domain','nls_date_format','deferred_segment_creation'
);