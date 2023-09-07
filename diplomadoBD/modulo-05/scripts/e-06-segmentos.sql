--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 02/12/2022
--@Descripción: Segmentos

define p_user = 'JOHAN05'

connect &p_user/&p_user

create table empleado(
  empleado_id   number(10,0)    constraint empleado_pk primary key,
  curp          varchar2(18)    constraint empleado_curp_uk unique,
  email         varchar2(100),
  foto          blob,
  cv            clob,
  perfil        varchar2(4000)
) segment creation immediate;

prompt creando un indice explicito
create index empleado_email_ix on empleado(email);

prompt mostrando segmentos de la tabla
col segment_name format a30
select
  tablespace_name,
  segment_name,
  segment_type,
  blocks,
  extents
from user_segments
where segment_name like '%EMPLEADO%';

prompt mostrando datos de user_lobs
col index_name format a30
col column_name format a30
select
  tablespace_name,
  segment_name,
  index_name,
  column_name
from user_lobs
where table_name = 'EMPLEADO';

drop table empleado cascade constraints purge;