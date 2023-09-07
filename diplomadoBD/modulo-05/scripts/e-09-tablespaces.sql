--@Author: Johan Axel Zarazua Ramirez
--@Date: 10/diciembre/2022
--@Desc: Revisa administración de tablespaces

define syslogon='sys/system2 as sysdba'
define t_user='m05_store_user'
define t_userlogon='&t_user/&t_user'

Prompt Conectando como sys
connect &syslogon

Prompt Creando tablespaces

Prompt Ejercicio 1, crear TS m05_store_tbs1
create tablespace m05_store_tbs1
  datafile 
    '/u01/app/oracle/oradata/JZRDIP02/m05_store_tbs1.dbf' size 30M
  extent management local autoallocate
  segment space management auto;

Prompt Ejercicio 2, crear TS m05_sotre_multiple_tbs
create tablespace m05_sotre_multiple_tbs
  datafile  
    '/u01/app/oracle/oradata/JZRDIP02/m05_store_multiple_01.dbf' size 15m,
    '/u01/app/oracle/oradata/JZRDIP02/m05_store_multiple_02.dbf' size 15m,
    '/u01/app/oracle/oradata/JZRDIP02/m05_store_multiple_03.dbf' size 15m
  extent management local autoallocate
  segment space management auto;

prompt Ejercicio 3, crear TS m05_store_tbs_custom
create tablespace m05_store_tbs_custom
  datafile 
    '/u01/app/oracle/oradata/JZRDIP02/m05_store_tbs_custom_o1.dbf' size 15m reuse
  autoextend on next 2m maxsize 40m
  nologging
  blocksize 8k
  offline
  extent management local uniform size 64k
  segment space management auto;

prompt Ejercicio 4, consultar tablespaces creados
select tablespace_name, status, contents from dba_tablespaces;

prompt Ejercicio 5, creacion de usuario m05_store_user
create user &t_user identified by &t_user quota unlimited on m05_store_tbs1
  default tablespace m05_store_tbs1;
grant create session, create table, create procedure to &t_user;

prompt Ejercicio 6, crear tabla store_data con el usuario m05_store_user
connect &t_userlogon

create table store_data(
  c1 char(1024),
  c2 char(1024)
) segment creation deferred;

prompt Ejercicio 7, procedimeinto para llenar TS
create or replace procedure sp_e6_reserva_extensiones is
  v_extensiones number;
  v_total_espacio number;
begin
  v_extensiones := 0;
  loop
    begin
      execute immediate 'alter table store_data allocate extent';
    exception
      when others then
        if sqlcode = -1653 then
          dbms_output.put_line('Error: sin espaacio en TS');
          dbms_output.put_line('Codigo Error: ' || sqlcode);
          dbms_output.put_line('Mensaje Error: ' || sqlerrm);
          dbms_output.put_line(dbms_utility.format_error_backtrace);
          exit;
        end if;
    end;
  end loop;

  --total espacio asignado
  select sum(bytes)/1024/1024, count(*) into v_total_espacio, v_extensiones
    from user_extents
    where segment_name = 'STORE_DATA';

  dbms_output.put_line('Total de extensiones reservadas: ' || v_extensiones);
  dbms_output.put_line('Total espacio reservado en MB:   ' || v_total_espacio);
end;
/
show errors

prompt ejecutando procedimiento
set serveroutput on
exec sp_e6_reserva_extensiones
pause Analizar resultados, [Enter] para continuar 

prompt Ejercicio 8, modificar TS para almacenar
connect &syslogon

alter tablespace m05_store_tbs1 
  add datafile 
    '/u01/app/oracle/oradata/JZRDIP02/m05_store_tbs2.dbf' size 10M;

prompt Ejercicio 9, ejecutar nuevamente el programa para confirmar resultados
connect &t_userlogon
set serveroutput on
exec sp_e6_reserva_extensiones
pause Analizar resultados, [Enter] para continuar

prompt Ejercicio 10 consultar tablespaces
connect &syslogon
select t.tablespace_name, count(s.tablespace_name) as total_segmentos
  from dba_tablespaces t 
  left join dba_segments s on t.tablespace_name = s.tablespace_name
  group by t.tablespace_name
  order by 2 desc;

pause Analizar los resultados, [Enter] para continuar

prompt ejecunatdo consultas de datos de los data files
@e-10-data-files.sql

prompt limpieza
connect &syslogon

prompt eliminando ts usuario y usuario
drop tablespace m05_store_tbs1 including contents and datafiles;
drop tablespace m05_sotre_multiple_tbs including contents and datafiles;
drop tablespace m05_store_tbs_custom including contents and datafiles;

drop user &t_user cascade;

prompt Listo
exit