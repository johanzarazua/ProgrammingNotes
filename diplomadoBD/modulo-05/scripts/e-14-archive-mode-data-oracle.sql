--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 13/01/2023
--@Descripción: Consultas modo archive

connect sys/system2 as sysdba

--1
prompt Consultando v$database
select name, log_mode, archivelog_compression
from v$database;

--2
prompt segunda consulta
select dest_id, dest_name, status, binding, destination
from v$archive_dest
where dest_name in ('LOG_ARCHIVE_DEST_1','LOG_ARCHIVE_DEST_2');

--3
prompt Consultando todos los datos de los redo logs
alter session set nls_date_format='yyyy/mm/dd hh24:mi:ss';
select * from v$log

select * from v$log_history;

select * from v$archived_log;