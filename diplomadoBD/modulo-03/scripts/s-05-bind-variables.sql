--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 22/10/2022
--@Descripción: Comparacion entre usar o no usar bind variables

prompt conectando como sysdba
connect sys/system2 as sysdba

prompt creando user01 y asignando privilegios
create user user01 identified by user01 quota unlimited on users;
grant create session, create table to user01;

prompt creando tabla de prueba
create table user01.test(
    id number
  ) segment creation immediate;

-- reset shared pool, remueve toda la informacion del shared pool
prompt haciendo reset a shared pool
alter system flush shared_pool;

-- habilitar instruccion de timepo
prompt iniciando conteo de timepo
set timing on

prompt 1. bloque pl/sql con bind varianles
begin
  for i in 1..100000 loop
    execute immediate 'insert into user01.test(id) values(:ph1)' using i;
  end loop;
end;
/

prompt consulta a la tabla v$sqlstats con bind variables
select 
  executions,
  loads,
  parse_calls,
  disk_reads,
  buffer_gets,
  cpu_time/1000 cpu_time_ms,
  elapsed_time/100 elapsed_time_ms
from v$sqlstats
where 
  sql_text = 'insert into user01.test(id) values(:ph1)'
;

prompt 2. bloque pl/sql sin bind varianles
begin
  for i in 1..100000 loop
    execute immediate 'insert into user01.test(id) values('||i||')';
  end loop;
end;
/

prompt consulta a la tabla v$sqlstats sin bind variables
select 
  count(*) t_rows, 
  sum(executions) executions, 
  sum(loads) loads,
  sum(parse_calls) parse_calls,
  sum(disk_reads) disk_reads,
  sum(buffer_gets) buffer_gets,
  sum(cpu_time)/1000 cpu_time_ms,
  sum(elapsed_time)/1000 elapsed_time_ms
from v$sqlstats
where 
  sql_text like 'insert into user01.test(id) values(%)' and
  sql_text <> 'insert into user01.test(id) values(:ph1)'
;

select count(*) from user01.test;

prompt deteniendo conteo de tiempo
set timing off

prompt haciendo reset a shared pool
alter system flush shared_pool;

prompt haciendo limpieza
drop user user01 cascade;