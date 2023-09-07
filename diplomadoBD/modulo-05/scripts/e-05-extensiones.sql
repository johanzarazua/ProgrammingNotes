--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 02/12/2022
--@Descripción: Extensiones

define p_user = 'JOHAN05'

prompt consultando extentensiones, conectando como sys
connect sys/system2 as sysdba

begin
  execute immediate 'drop table &p_user..t04_ejemplo_extensiones';
exception
  when others then
    null;
end;
/

prompt creando tabla prueba.
create table &p_user..t04_ejemplo_extensiones(
  str char(1024)
);

prompt consultando datos de las extensiones
select
  segment_type, 
  tablespace_name,
  file_id,
  extent_id,
  block_id,
  bytes/1024 extent_size_kb,
  blocks
from dba_extents
where segment_name = 'T04_EJEMPLO_EXTENSIONES' and 
      owner = '&p_user'
;

prompt insertando los 100 registros
begin
  for v_index in 1..100 loop
    insert into &p_user..t04_ejemplo_extensiones values ('A');
  end loop;
end;
/
commit;

prompt consultando datos de las extensiones despues de insertar
select
  segment_type, 
  tablespace_name,
  file_id,
  extent_id,
  block_id,
  bytes/1024 extent_size_kb,
  blocks
from dba_extents
where segment_name = 'T04_EJEMPLO_EXTENSIONES' and 
      owner = '&p_user'
;

prompt mostrando estado de los bloques
set serveroutput on
declare
  v_unformatted_blocks  number;  --número de bloques asignados y no formateados
  v_unformatted_bytes   number;  --número de bytes asignados y no formateados
  v_fs1_blocks          number;  --número de bloques con espacio de 0 hasta 25%
  v_fs1_bytes           number;  --bloques en bytes con espacio de 0 hasta 25%
  v_fs2_blocks          number;  --número de bloques con espacio entre 25% y 50%
  v_fs2_bytes           number;  --bloques en bytes con espacio de 25 hasta 50%
  v_fs3_blocks          number;  --número de bloques con espacio entre 50% y 75%
  v_fs3_bytes           number;  --bloques en bytes con espacio de 50 hasta 75%
  v_fs4_blocks          number;  --número de bloques con espacio entre 75% y 100%
  v_fs4_bytes           number;  --bloques en bytes con espacio de 75 hasta 100%
  v_full_blocks         number;  --número de bytes sin espacio
  v_full_bytes          number;  --bloques en bytes sin espacio 

begin
  
  dbms_space.space_usage(
    '&p_user',
    'T04_EJEMPLO_EXTENSIONES',
    'TABLE',
    v_unformatted_blocks,
    v_unformatted_bytes,
    v_fs1_blocks,
    v_fs1_bytes,
    v_fs2_blocks,
    v_fs2_bytes,
    v_fs3_blocks,
    v_fs3_bytes,
    v_fs4_blocks,
    v_fs4_bytes,
    v_full_blocks,
    v_full_bytes
  );

  dbms_output.put_line('Mostrando valores de los bloques');
  dbms_output.put_line('v_unformatted_blocks = ' || v_unformatted_blocks);
  dbms_output.put_line('v_unformatted_bytes = ' || v_unformatted_bytes);
  dbms_output.put_line('v_fs1_blocks = ' || v_fs1_blocks);
  dbms_output.put_line('v_fs1_bytes = ' || v_fs1_bytes);
  dbms_output.put_line('v_fs2_blocks = ' || v_fs2_blocks);
  dbms_output.put_line('v_fs2_bytes = ' || v_fs2_bytes);
  dbms_output.put_line('v_fs3_blocks = ' || v_fs3_blocks);
  dbms_output.put_line('v_fs3_bytes = ' || v_fs3_bytes);
  dbms_output.put_line('v_fs4_blocks = ' || v_fs4_blocks);
  dbms_output.put_line('v_fs4_bytes = ' || v_fs4_bytes);
  dbms_output.put_line('v_full_blocks = ' || v_full_blocks);
  dbms_output.put_line('v_full_bytes = ' || v_full_bytes);

end;
/

prompt eliminando 100 registros
begin
  execute immediate 'truncate table &p_user..t04_ejemplo_extensiones';
exception
  when others then
    null;
end;
/

prompt mostrando estado de los bloques desoues de eliminar
set serveroutput on
declare
  v_unformatted_blocks  number;  --número de bloques asignados y no formateados
  v_unformatted_bytes   number;  --número de bytes asignados y no formateados
  v_fs1_blocks          number;  --número de bloques con espacio de 0 hasta 25%
  v_fs1_bytes           number;  --bloques en bytes con espacio de 0 hasta 25%
  v_fs2_blocks          number;  --número de bloques con espacio entre 25% y 50%
  v_fs2_bytes           number;  --bloques en bytes con espacio de 25 hasta 50%
  v_fs3_blocks          number;  --número de bloques con espacio entre 50% y 75%
  v_fs3_bytes           number;  --bloques en bytes con espacio de 50 hasta 75%
  v_fs4_blocks          number;  --número de bloques con espacio entre 75% y 100%
  v_fs4_bytes           number;  --bloques en bytes con espacio de 75 hasta 100%
  v_full_blocks         number;  --número de bytes sin espacio
  v_full_bytes          number;  --bloques en bytes sin espacio 

begin
  
  dbms_space.space_usage(
    '&p_user',
    'T04_EJEMPLO_EXTENSIONES',
    'TABLE',
    v_unformatted_blocks,
    v_unformatted_bytes,
    v_fs1_blocks,
    v_fs1_bytes,
    v_fs2_blocks,
    v_fs2_bytes,
    v_fs3_blocks,
    v_fs3_bytes,
    v_fs4_blocks,
    v_fs4_bytes,
    v_full_blocks,
    v_full_bytes
  );

  dbms_output.put_line('Mostrando valores de los bloques');
  dbms_output.put_line('v_unformatted_blocks = ' || v_unformatted_blocks);
  dbms_output.put_line('v_unformatted_bytes = ' || v_unformatted_bytes);
  dbms_output.put_line('v_fs1_blocks = ' || v_fs1_blocks);
  dbms_output.put_line('v_fs1_bytes = ' || v_fs1_bytes);
  dbms_output.put_line('v_fs2_blocks = ' || v_fs2_blocks);
  dbms_output.put_line('v_fs2_bytes = ' || v_fs2_bytes);
  dbms_output.put_line('v_fs3_blocks = ' || v_fs3_blocks);
  dbms_output.put_line('v_fs3_bytes = ' || v_fs3_bytes);
  dbms_output.put_line('v_fs4_blocks = ' || v_fs4_blocks);
  dbms_output.put_line('v_fs4_bytes = ' || v_fs4_bytes);
  dbms_output.put_line('v_full_blocks = ' || v_full_blocks);
  dbms_output.put_line('v_full_bytes = ' || v_full_bytes);

end;
/