--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 29/01/2023
--@Descripción: Uso de tablespaces.

define syslogon = 'sys/system2 as sysdba'
define labUser = 'm05_911_user'
define labUserLogon =  'm05_911_user/m05_911_user'

prompt Conectando como sys
conn &syslogon

set serveroutput on
prompt Realizando limpieza
declare
  v_count number;

  cursor cur_tablespaces is 
    select tablespace_name from dba_tablespaces
      where tablespace_name in ('M05_911_TS', 'M05_911_IX_TS');

begin
  select count(*) into v_count from dba_users where username = upper('&labUser');
  if v_count > 0 then
    dbms_output.put_line('Eliminando usuario &labUser');
    execute immediate 'drop user &labUser cascade';
  end if;

  for r in cur_tablespaces loop
    dbms_output.put_line('Eliminando ' || r.tablespace_name);
    execute immediate 'drop tablespace ' || r.tablespace_name || ' including contents and datafiles';
  end loop;
end;
/

prompt 1. Creando tablespaces.
prompt creando tablespace m05_911_ts 
create tablespace m05_911_ts
  datafile
    '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_01.dbf' size 15M,
    '/unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_02.dbf' size 15M,
    '/unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_03.dbf' size 15M,
    '/unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_04.dbf' size 15M,
    '/unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_05.dbf' size 15M
  extent management local autoallocate
  segment space management auto;

prompt creando tablespace m05_911_ix_ts
create tablespace m05_911_ix_ts
  datafile 
    '/unam-diplomado-bd/u31/app/oracle/oradata/JZRDIP02/m05_911_ts_05.dbf' size 5M
  autoextend on next 1M maxsize 30M
  extent management local autoallocate
  segment space management auto;

prompt Consultando tablespaces creados
select tablespace_name, status, contents 
  from dba_tablespaces
  where tablespace_name like 'M05_911%';

prompt 2. CReando usuario m05_911_user
create user &labUser identified by &labUser
  quota unlimited on m05_911_ts
  quota unlimited on m05_911_ix_ts
  default tablespace m05_911_ts;

grant create session, create table, create procedure to &labUser;

prompt 3. Creacion de directorio para tabla externa.
create or replace directory ext_tab_data as '/tmp/dip/911';
grant read,write on directory ext_tab_data to &labUser;

prompt Conectando como &labUser
conn &labUserLogon

prompt creando tabla externa
create table llamada_911_ext(
  address           varchar2(50),
  type              varchar2(50),
  call_ts           date,
  latitude          number(10,6),
  longitude         number(10,6),
  report_location   varchar2(40),
  incident_number   varchar2(12)
)organization external (
  type oracle_loader
  default directory ext_tab_data
  access parameters (
    records delimited by newline
    badfile ext_tab_data: 'llamada_911_bad.log'
    logfile ext_tab_data: 'llamada_911_err.log'
    fields terminated by ',' 
    optionally enclosed by '"' 
    date_format date mask "mm/dd/yyyy hh:mi:ss am"
    lrtrim
    missing field values are null
    (
      address,type,call_ts,latitude,longitude,report_location,incident_number
    )
  )
  location ('calls-911-50m.csv') 
) reject limit 100;

prompt realizando prueba en tabla externa
select * from llamada_911_ext where rownum <=10;

pause [Enter] para crear tabla permanente

prompt Creando tabla permanente
create table llamada_911(
  address           varchar2(50),
  type              varchar2(50),
  call_ts           date,
  latitude          number(10,6),
  longitude         number(10,6),
  report_location   varchar2(40),
  incident_number   varchar2(12)
) nologging;

prompt creando indices
create index incident_number_ix on llamada_911(incident_number) tablespace m05_911_ix_ts;
create index address_ix on llamada_911(address) tablespace m05_911_ix_ts;

prompt insertando registros de tabla tenporal en tabla permanente
insert /*+ append */ into llamada_911 select * from llamada_911_ext;
commit;

prompt 4. Realizando consultas
prompt conectando como sys
conn &syslogon

prompt cnsultando segmentos
select tablespace_name, segment_name, extents, bytes/1024/1024 MB_reservados  
  from dba_segments 
  where tablespace_name like 'M05_911%';

prompt consultando datfiles
col file_name for a70
select tablespace_name, file_id, file_name, bytes/1024/1024 size_MB, 
  blocks ,online_status, autoextensible
  from dba_data_files
  where tablespace_name like 'M05_911%';

prompt consultando segmentos, extensiones y datfiles
select s.tablespace_name, s.segment_name, d.file_name, sum(s.extents) 
  from dba_segments s, dba_data_files d
  where s.tablespace_name = d.tablespace_name and s.tablespace_name like 'M05_911%'
  group by s.tablespace_name, s.segment_name, d.file_name;

prompt 5. Proceso de administracion.
prompt 5.1 Colocando en modo offline el datafile 1 de m05_911_ts
alter database 
  datafile '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_01.dbf' offline;

prompt 5.2 Colocando el tablespace m05_911_ts para labores adminstrativas 
recover datafile 6;
alter database 
  datafile '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_01.dbf' online;
alter tablespace m05_911_ts offline normal;

prompt 5.3 Intentando insertar un registro con el usuario &labUser, se espera error
conn &labUserLogon
insert into 
  llamada_911(address, type, call_ts, latitude, longitude, report_location, incident_number)
  values('calle prueba', 'reporte', to_date('04/02/2023', 'dd/mm/yyyy'), 10.10, 10.10, '---', '###');

prompt 5.4 Consultando estado de datfiles
conn &syslogon
col file_name for a70
select tablespace_name, file_id, file_name, online_status
  from dba_data_files
  where tablespace_name = 'M05_911_TS';


prompt 6. Reubicando datafiles
prompt Modo offline
prompt moviendo archivos en S.O.
!mv /unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_01.dbf /unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_a.dbf
!mv /unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_02.dbf /unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_b.dbf
!mv /unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_03.dbf /unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_c.dbf
!mv /unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_04.dbf /unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_d.dbf
!mv /unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_05.dbf /unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_e.dbf


prompt modficando nombre en BD
alter tablespace m05_911_ts
  rename datafile 
    '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_01.dbf',
    '/unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_02.dbf',
    '/unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_03.dbf',
    '/unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_04.dbf',
    '/unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_05.dbf'
  to
    '/unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_a.dbf',
    '/unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_b.dbf',
    '/unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_c.dbf',
    '/unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_d.dbf',
    '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_e.dbf'
;

prompt colocnaod ts en modo online
alter tablespace m05_911_ts online;

prompt modo online
alter database 
  move datafile '/unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_a.dbf' 
    to '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_01.dbf';
alter database 
  move datafile '/unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_b.dbf' 
    to '/unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_02.dbf';
alter database 
  move datafile '/unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_c.dbf' 
    to '/unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/m05_911_ts_03.dbf';
alter database 
  move datafile '/unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/m05_911_ts_d.dbf' 
    to '/unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/m05_911_ts_04.dbf';
alter database 
  move datafile '/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/m05_911_ts_e.dbf' 
    to '/unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/m05_911_ts_05.dbf';
  
prompt reconsttuyendo indices
alter index &labUser..incident_number_ix rebuild;
alter index &labUser..address_ix rebuild;

prompt consultando datos de la tabla
select count(*) from &labUser..llamada_911;

prompt listo!!!