--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 02/12/2022
--@Descripción: encadenamiento de bloques

define p_user = 'JOHAN05'

Prompt Conectando como sysdba
connect sys/system2 as sysdba

whenever sqlerror exit rollback;

Prompt Mostrando el contenido del parametro db_block_size
show parameter db_block_size

Prompt Conectando como JOHAN05 para generar una tabla grande
connect &p_user/&p_user

begin 
  execute immediate 'drop table t03_row_chaining';
exception
  when others then
    null;
end;
/

create table t03_row_chaining(
  id number(10,0) constraint t03_row_chaining_pk primary key,
  c1 char(2000) default 'A',
  c2 char(2000) default 'B',
  c3 char(2000) default 'C',
  c4 char(2000) default 'D',
  c5 char(2000) default 'E'
);

Prompt Insertando un primer registro
insert into t03_row_chaining(id) values(1);
commit;

Prompt Mostrando el tamaño de la columna c1
select length(c1)
from t03_row_chaining
where id = 1;

Prompt Actualizando estadisticas
analyze table t03_row_chaining compute statistics;

Prompt Consultando metadatos
select tablespace_name, pct_free, pct_used, num_rows, blocks, empty_blocks,
  avg_space/1024 avg_space_kb, chain_cnt, avg_row_len/1024 avg_row_len_kb
from user_tables
where table_name = 'T03_ROW_CHAINING';

Pause Analizar [enter] corregir problema

Prompt Creando un nuevo tablespace con bloques de 16k, conectando con sys
connect sys/system2 as sysdba

alter system set db_16k_cache_size=16K scope = memory;


begin
  execute immediate 'drop tablespace dip_m05_01 including contents and datafiles';
exception
  when others then
    null;
end;
/

create tablespace dip_m05_01
blocksize 16K 
datafile '/u01/app/oracle/oradata/JZRDIP02/dip_m05_01.dbf'
size 20m
extent management local uniform size 1M;

Prompt Otorgando quota de almacenamiento al usuario JOHAN05 en el nuevo tablespace
alter user &p_user quota unlimited on dip_m05_01;

Prompt Moviendo datos al nuevo TS, conectando como JOHAN05
connect &p_user/&p_user

alter table t03_row_chaining move tablespace dip_m05_01;

Prompt Reconstruyendo el indice por efectos del cambio del TS
alter index t03_row_chaining_pk rebuild;

Prompt Actualizando estadisticas nuevamente
analyze table t03_row_chaining compute statistics;

Prompt Consultando metadatos nuevamente
select tablespace_name, pct_free, pct_used, num_rows, blocks, empty_blocks,
  avg_space/1024 avg_space_kb, chain_cnt, avg_row_len/1024 avg_row_len_kb
from user_tables
where table_name = 'T03_ROW_CHAINING';

Pause Analizar [enter] 

Prompt Mostrando el DDL de la tabla modificada
set heading off
set echo off
set pages 999
set long 90000
select dbms_metadata.get_ddl('TABLE','T03_ROW_CHAINING','&p_user')
from dual;

Pause Prueba terminada, [enter] limpieza

Prompt Eliminando tabla t03_row_chaining
drop table t03_row_chaining;

Prompt Eliminando TS
connect sys/system2 as sysdba
drop tablespace dip_m05_01 including contents and datafiles;

exit