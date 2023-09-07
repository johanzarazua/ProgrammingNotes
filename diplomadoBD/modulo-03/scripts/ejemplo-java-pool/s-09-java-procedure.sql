--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 28/10/2022
--@Descripción: Ejecucion de java procedure  y validacion de uso del java pool

prompt connectando como userJava
connect userJava/userJava

prompt creando procedimiento almacenado
create or replace procedure sp_resizeImage(
  p_file_path varchar2,
  p_width number,
  p_height number
) as 
  language java
  name 'mx.edu.unam.fi.dipbd.ResizeImage.resizeImage(java.lang.String,int,int)';
/
show errors

prompt invocando procedimeinto
exec sp_resizeImage('/tmp/paisaje.png', 734, 283);

prompt mostarando resulado
!ls -lh /tmp/paisaje.png
!ls -lh /tmp/output-paisaje.png

prompt connectando como sysdba
connect sys/system2 as sysdba

prompt mostrando historial de cambio en memeoria para java pool
col component format a15
col parameter format a15
alter session set nls_date_format = 'dd/mm/yyyy hh24:mi:ss';
select 
  component,
  oper_type,
  trunc(initial_size/102/1024, 2) initial_size_mb,
  trunc(target_size/102/1024, 2) target_size_mb,
  trunc(final_size/102/1024, 2) final_size_mb,
  start_time, parameter
from v$sga_resize_ops
where component = 'java pool'
order by start_time;

prompt realizando limpieza
drop user userJava cascade;