--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 03/12/2022
--@Descripción: Tablespaces

prompt conectando como sys
connect sys/system2 as sysdba

col property_name format a30
col property_value format a30
col tablespace_name format a30
col username format a30

prompt mostrando datos del TS usando database_properties.
select 
  property_name,
  property_value
from database_properties
where property_name like '%TABLESPACE%';

prompt mostrando datos de los tablespaces usando user_users JOHAN05
define p_user = 'JOHAN05'
connect &p_user/&p_user
select 
  default_tablespace, 
  temporary_tablespace,
  local_temp_tablespace
from user_users;

prompt mostrando TS undo empleado por todos los usuarios
connect sys/system2 as sysdba
show parameter undo_tablespace

prompt mostrando quota de almacenamiento para los usuarios
select 
  tablespace_name,
  username,
  bytes/1024/1024 quota_mb,
  blocks,
  max_blocks
from dba_ts_quotas;

prompt mostrando los datos del TS temp
select 
  tablespace_name,
  tablespace_size/1024/1024 ts_size_mb,
  allocated_space/1024/1024 allocated_space_mb,
  free_space/1024/1024 free_space_mb
from dba_temp_free_space;

-- Modificar el ts temporal
-- ALter database default temporary tablespace [TS_name] 