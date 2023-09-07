--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 18/02/2023
--@Descripción: Creacion de un application container

spool ./../../spools/m07-e03-08.txt replace
prompt CReando aplication contaniner en JZRDIP03

!sh s-030-stop-cdb.sh jzrdip04 system4
!sh s-030-start-cdb.sh jzrdip03 system3

prompt Conectando a jzrdip03
connect sys/system3@jzrdip03 as sysdba

prompt Crear aplication container jzrdip03_appc1
create pluggable database jzrdip03_appc1 as application container
  admin user admin identified by admin
  file_name_convert=(
    '/u01/app/oracle/oradata/JZRDIP03/pdbseed',
    '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_appc1'
  );

prompt abriendo jzrdip03_appc1
alter pluggable database jzrdip03_appc1 open read write;
prompt conextando a jzrdip03_app1
alter session set container=jzrdip03_appc1;

prompt mostrando datos del container
show con_id
show con_name

pause Analizar resultados, [Enter] para continuar

prompt crear PDB jzrdip03_appc1_s1
create pluggable database jzrdip03_appc1_s1
  admin user admin identified by admin
  file_name_convert=(
    '/u01/app/oracle/oradata/JZRDIP03/pdbseed',
    '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_appc1/jzrdip03_appc1_s1'
  );

prompt abriendo jzrdip03_appc1_s1
alter pluggable database jzrdip03_appc1_s1 open read write;

prompt realizar sync entre pdb y app container
alter session set container=jzrdip03_appc1_s1;
alter pluggable database application all sync;

prompt crear un application app1
alter session set container=jzrdip03_appc1;
alter pluggable database application jzrdip03_appc1_app1 begin install '1.0';

-- parametro para indicar ruta para guardar datafiles de la nueva pdb
alter system set db_create_file_dest='/u01/app/oracle/oradata' scope=memory;

prompt creando objetos comunes
prompt creando TS
create tablespace app1_test01_ts
  datafile size 1m autoextend on next 1m;

prompt creando usuario
create user app1_test_user identified by johan
  default tablespace app1_test01_ts
  quota unlimited on app1_test01_ts
  container=all;

grant create session, create table, create procedure to app1_test_user;

prompt creando tabla 
create table app1_test_user.carrera(
  id number(10,0) constraint carrera_pk primary key,
  nombre varchar2(40) 
);

prompt insertando datos
insert into app1_test_user.carrera (id, nombre) values (1,'Ing. Computacion');
insert into app1_test_user.carrera (id, nombre) values (2,'Ing. Petrolera');
insert into app1_test_user.carrera (id, nombre) values (3,'Medicina');

prompt termianndo de asociar objetos comunes
alter pluggable database application jzrdip03_appc1_app1 end install;

prompt realizar sync entre pdb y app
alter session set container=jzrdip03_appc1_s1;
show con_name
alter pluggable database application jzrdip03_appc1_app1 sync;

prompt mostrando datos de objetos comunes 
select * from app1_test_user.carrera;
pause Analizar resulato [Enter] para continuar

prompt creando  una nueva pdb jzrdip03_appc1_s2
alter session set container=jzrdip03_appc1;
prompt crear PDB jzrdip03_appc1_s2
create pluggable database jzrdip03_appc1_s2
  admin user admin identified by admin
  file_name_convert=(
    '/u01/app/oracle/oradata/JZRDIP03/pdbseed',
    '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_appc1/jzrdip03_appc1_s2'
  );

prompt abrir jzrdip03_appc1_s2
alter pluggable database jzrdip03_appc1_s2 open read write;

prompt mostrar datos en jzrdip03_appc1_s2 sin hacer sync
alter session set container=jzrdip03_appc1_s2;
select * from app1_test_user.carrera;
pause Analizar resulato [Enter] para continuar

prompt hacer sync y mostrar datos
alter pluggable database application jzrdip03_appc1_app1 sync;
select * from app1_test_user.carrera;
pause Analizar resulato [Enter] para continuar

prompt GEnerando version 1.1 de jzrdip03_appc1_app1
alter session set container=jzrdip03_appc1;

alter pluggable database application jzrdip03_appc1_app1 
  begin upgrade '1.0' to '1.1';

prompt insertar un nuevo dato
insert into app1_test_user.carrera(id, nombre) values(4, 'Filosofia');

prompt agregando  una nueva columna
alter table app1_test_user.carrera add total_creditos number;

prompt agregando procedimiento almacenado
create or replace procedure app1_test_user.p_asigna_creditos(p_carrera_id number) is
  update app1_test_user.carrera set total_creditos = id + 10 where id = p_carrera_id;
end; 
/
show errors 

prompt indicando final de upgrade
alter pluggable database application jzrdip03_appc1_app1 end upgrade;


prompt revisar la nueva version
alter session set container=jzrdip03_appc1_s1;
prompt haciendo sync
alter pluggable database application jzrdip03_appc1_app1 sync;

prompt invocando sp 
exec app1_test_user.p_asigna_creditos(1);

prompt mostrando datos de tabla
select * from app1_test_user.carrera;

pause Analizar resultado [Enter] para continuar

prompt realizando consultas a DD
alter session set container=jzrdip03_appc1;

col app_name format a20
col app_version format a10
select app_name, app_version, app_status from dba_applications;

prompt datos de PDBs asociadas a un app container
select c.name, ap.app_name, ap.app_version, ap.app_status from dba_app_pdb_status ap
join v$containers c on c.con_uid = ap.con_uid;

pause Analizar resultados [Enter] para hacer limpieza
alter session set container=jzrdip03_appc1;
alter pluggable database jzrdip03_appc1_s1 close;
alter pluggable database jzrdip03_appc1_s2 close;

drop pluggable database jzrdip03_appc1_s1 including datafiles;
drop pluggable database jzrdip03_appc1_s2 including datafiles;

alter pluggable database application jzrdip03_appc1_app1 begin uninstall;

drop tablespace app1_test01_ts including contents and datafiles;
drop user app1_test_user cascade;

alter pluggable database application jzrdip03_appc1_app1 end uninstall;

alter session set container=cdb$root;
alter pluggable database jzrdip03_appc1 close;
drop pluggable database jzrdip03_appc1 including datafiles;

spool off
exit