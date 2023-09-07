--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 13/01/2023
--@Descripción: Datos undo

set verify off

define test_user = 'JOHAN05'
define test_user_logon = 'JOHAN05/JOHAN05'

connect sys/system2 as sysdba

Prompt 1. Mostrando tablespace undo en uso
show parameter undo_tablespace

Pause [enter] 

Prompt 2. Creando un nuevo tablespace
set serveroutput on
declare
  v_count number;
begin
  select count(*) into v_count
  from dba_tablespaces
  where tablespace_name = 'UNDOTBS2';

  if v_count > 0 then
    dbms_output.put_line('Eliminando unodtbs2');
    execute immediate 'alter system set undo_tablespace=''undotbs1'' scope=memory';
    execute immediate 'drop tablespace undotbs2 including contents and datafiles';
  end if;
end;
/

create undo tablespace undotbs2
  datafile '/u01/app/oracle/oradata/JZRDIP02/undotbs_2.dbf' size 30M
    autoextend off
    extent management local autoallocate;

Prompt 3. Configurando el nuevo TS undo
alter system set undo_tablespace='undotbs2' scope=memory;

Prompt 4. Mostrando el parametro undo_tablespace
show parameter undo_tablespace
Pause Analizar resultados [enter]

Prompt 5. Mostrando estadísticas de los datos undo
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

select * from (
  select 
    begin_time, 
    end_time, 
    undotsn, 
    undoblks, 
    txncount, 
    maxqueryid,
    maxquerylen,
    activeblks, 
    unexpiredblks, 
    expiredblks, 
    tuned_undoretention, 
    tuned_undoretention/60 tuned_undo_min
  from v$undostat
  order by begin_time desc
) where rownum <= 20;

Pause 6. Analizar resultados [Enter] para continuar
------------------------------------------------------
prompt 7. MOstrando dba_tablespaces
select * from(
  select u.begin_time, u.end_time, u.undotsn, t.name
    from v$undostat u, v$tablespace t
    where u.undotsn = t.ts#
    order by 1 desc  
);

Pause Analizar resultados [Enter] para continuar

prompt 8. Mostrando datos del nuevo TS.
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt 9. creacion y poblado de tabla
declare
  v_count number;
begin
  select count(*) into v_count from all_sequences where sequence_name = 'SEC_RANDOM_STR_2'
    and sequence_owner = upper('&test_user');
  
  if v_count > 0 then
    execute immediate 'drop sequence &test_user..sec_random_str_2';
  end if;

  select count(*) into v_count from all_tables where table_name = 'RANDOM_STR_2'
    and owner = upper('&test_user');

  if v_count > 0 then
    execute immediate 'drop table &test_user..random_str_2 purge';
  end if;

end;
/

prompt creando tabla
create table &test_user..random_str_2 (
  id number,
  cadena varchar2(1024)
) nologging;

prompt creando sequencia
create sequence &test_user..sec_random_str_2;

prompt sequencia actual de los redologs
select group#, thread#, sequence#, bytes/1024/1024 size_mb from v$log;

Pause [Enter] para comenzar con la craga de datos
begin
  for v_index in 1..50000 loop
    insert /*+ append */ into &test_user..random_str_2
      values(&test_user..sec_random_str_2.nextval, dbms_random.string('X',1024));
  end loop;
end;
/

prompt sequencia actual de los redologs
select group#, thread#, sequence#, bytes/1024/1024 size_mb from v$log;

Pause Analizar resultado, [Enter] para continuar

prompt Mostrando estadisticas de datos undo nuevamente
select * from (
  select 
    begin_time, 
    end_time, 
    undotsn, 
    undoblks, 
    txncount, 
    maxqueryid,
    maxquerylen,
    activeblks, 
    unexpiredblks, 
    expiredblks, 
    tuned_undoretention, 
    tuned_undoretention/60 tuned_undo_min
  from v$undostat
  order by begin_time desc
) where rownum <= 20;

prompt revisnaod datos de TS
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt 10. Borrar datos para replicar error
prompt borrano del 1 a 10000
delete from &test_user..random_str_2 where id between 1 and 10000;

prompt revisnaod datos de TS
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt borrano del 10001 a 20000
delete from &test_user..random_str_2 where id between 10001 and 20000;

prompt revisnaod datos de TS
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt borrano del 20001 a 30000
delete from &test_user..random_str_2 where id between 20001 and 30000;

prompt revisnaod datos de TS
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt borrano del 30001 a 40000
delete from &test_user..random_str_2 where id between 30001 and 40000;

prompt revisnaod datos de TS
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt borrano del 40001 a 50000
delete from &test_user..random_str_2 where id between 40001 and 50000;

prompt revisnaod datos de TS
select df.tablespace_name, df.blocks total_bloques, sum(f.blocks) bloques_libres,
  round(sum(f.blocks)/df.blocks*100,2) "%_bloques_libres"
  from dba_data_files df, dba_free_space f
  where df.tablespace_name = f.tablespace_name
    and df.tablespace_name = 'UNDOTBS2'
    group by df.tablespace_name, df.blocks;

Pause Analizar resultados [Enter] para continuar

prompt haciendo rollback
rollback;