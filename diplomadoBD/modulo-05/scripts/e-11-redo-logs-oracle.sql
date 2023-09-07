define syslogon = 'sys/system2 as sysdba'
define userlogon = 'JOHAN05/JOHAN05'

conn &syslogon

prompt 1. Mostrando archvios en el S.O.
--funciona solo con usuario oracle
!find /unam-diplomado-bd/disk-0*/app/oracle/oradata/JZRDIP02/redo* -name "redo*.log" -type f -exec ls -l {} +;

Prompt 2 a 4. COnsultas independeintes.
-- select * from v$log;

prompt 5. Agregar nuevos grupos de redo con dos miembros
prompt ceando grupo 4 de redo
alter database add logfile group 4 (
  '/unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo04a_60.log',
  '/unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo04b_60.log'
) size 60m blocksize 512;

prompt ceando grupo 5 de redo
alter database add logfile group 5 (
  '/unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo05a_60.log',
  '/unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo05b_60.log'
) size 60m blocksize 512;

prompt ceando grupo 6 de redo
alter database add logfile group 6 (
  '/unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo06a_60.log',
  '/unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo06b_60.log'
) size 60m blocksize 512;

prompt 6. Agregar tercer miembro a cada grupo
alter database add logfile member 
  '/unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo04c_60.log' to group 4;

alter database add logfile member 
  '/unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo05c_60.log' to group 5;

alter database add logfile member 
  '/unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo06c_60.log' to group 6;

prompt 7. Consultar nuevamente los grupos de redo
select * from v$log;

pause Analizar el resultado [Enter] para continuar

prompt 8. Consultar nuevamente los miembros
col member format a40
select * from v$logfile;

prompt 9. Forzar un log switch para liberar grupos 1, 2 y 3.
set serveroutput on
declare
  v_group number;
begin
  loop
    
    select group# into v_group from v$log where status = 'CURRENT';
    dbms_output.put_line('Grupo en uso: '||v_group);
    if v_group in (1,2,3) then
      execute immediate 'alter system switch logfile';
    else
      exit;
    end if;
  end loop;
end;
/

prompt 10. Confirmando grupo actual
select * from v$log;

pause Analizar resultado, [Enter] para continuar

prompt 11. Validnando que los grupos 1 a 3 no tengan status ACTIVE
declare
  v_count number;
begin
  select count(*) into v_count from v$log where status = 'ACTIVE';
  if v_count > 0 then
    dbms_output.put_line('Forzando checkpoint para sincornizar data files con db_buffer');
    execute immediate 'alter system checkpoint';
  end if;
end;
/

prompt 12. Confirmando que no existen grupos ACTIVE
select * from v$log;
pause Analizar resultado, [Enter] para continuar

prompt 13. Eliminar grupos 1, 2 y 3
alter database drop logfile group 1;
alter database drop logfile group 2;
alter database drop logfile group 3;

prompt 14. Consultar nuevamente los grupos de redo
select * from v$log;
pause Analizar el resultado [Enter] para continuar

prompt 15 y 16 eliminar archivos de redo en S.O.
prompt eliminando archivos del grupo 1.
!rm /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo01a.log
!rm /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo01b.log
!rm /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo01c.log

prompt eliminando archivos del grupo 2.
!rm /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo02a.log
!rm /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo02b.log
!rm /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo02c.log

prompt eliminando archivos del grupo 3.
!rm /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo03a.log
!rm /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo03b.log
!rm /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo03c.log

prompt 17. Mostrando archivos en S.O.
--funciona solo con usuario oracle
!find /unam-diplomado-bd/disk-0*/app/oracle/oradata/JZRDIP02/redo* -name "redo*.log" -type f -exec ls -l {} +;

prompt Listo!!!
exit