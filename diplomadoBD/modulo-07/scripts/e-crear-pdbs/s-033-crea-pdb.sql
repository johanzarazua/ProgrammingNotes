--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 10/02/2023
--@Descripción: Clonacion de una pdb y conectandola a una nueva CDB

spool ./../../spools/m07-e03-03.txt replace
prompt crear clon de una PDB, hacer plug en otra CDB - manual

prompt inciando jzrdip03
!sh s-030-start-cdb.sh jzrdip03 system3

prompt conectando a jzrdip03 (root)
conn sys/system3@jzrdip03 as sysdba

prompt cerrando la pdb
alter pluggable database jzrdip03_s1 close;

prompt haciendo unplug de jzrdip03_s1
alter pluggable database jzrdip03_s1 unplug into '/home/oracle/backups/jzrdip03_s1.xml';

prompt mostrando datos de las PDBs
show pdbs

prompt mostrando datos de dba_pdbs
select pdb_id, pdb_name, status from dba_pdbs;

pause Analizar [Enter] para continuar

prompt eliminar la PDB manteniendo sus datafiles
drop pluggable database jzrdip03_s1 keep datafiles;

prompt  Mover la PDB a su nuevo destino a /home/oracle/backups/jzrdip03_s1
prompt no olvidar actualizar las rutas en el xml
pause [Enter] para continuar
/*
  los datafiles pueden ser ubicados en cualquier directorio, dado que trabajamos
  en la misma pc se pueden quedar en la ubicacion actual, pero en este caso se moveran
  a /home/oracle/backups/jzrdip03_s1 , se deben incluir metadatos xml
*/

prompt Hacer plug en JZRDIP04
prompt deteniendo jzrdip03
!sh s-030-stop-cdb.sh jzrdip03 system3

prompt iniciando jzrdip04
!sh s-030-start-cdb.sh jzrdip04 system4

prompt ingresando a jzrdip04
conn sys/system4@jzrdip04 as sysdba
show con_id
show con_name

prompt  1. validar compatibilidad 
set serveroutput on
declare
  v_compatible boolean;
begin
  v_compatible := dbms_pdb.check_plug_compatibility(
    pdb_descr_file=>'/home/oracle/backups/jzrdip03_s1/jzrdip03_s1.xml',
    pdb_name=>'jzrdip03_s1'
  );
  if v_compatible then
    dbms_output.put_line('COMPATIBLE');
  else
    raise_application_error(-20001, 'PDB jzrdip03_s1 incompatible con jzrdip03');
  end if;
end;
/

pause Validar resultados [Enter] para continuar

prompt agregar la nueva PDB
create pluggable database jzrdip04_m3 using '/home/oracle/backups/jzrdip03_s1/jzrdip03_s1.xml'
  file_name_convert=(
    '/home/oracle/backups/jzrdip03_s1/',
    '/u01/app/oracle/oradata/JZRDIP04/jzrdip04_m3'
  );

prompt MOstrando datos de las PDBs
show pdbs

prompt mostrando datos de dba_pdbs
select pdb_id, pdb_name, status from dba_pdbs;
pause Analizar resultados [Enter] para continuar

prompt Abriendo PDB migrada jzrdip04_m3
alter pluggable database jzrdip04_m3 open read write;

prompt conectando a jzrdip04_m3
alter session set container = jzrdip04_m3;

prompt mostrando datos de la PDB
show con_id
show con_name

pause Analizar resultado [Enter] para comenzar con la limpieza
prompt Regresando a JZRDIP04 (root)
alter session set container = cdb$root;

prompt cerrando PDB jzrdip04_m3
alter pluggable database jzrdip04_m3 close;

prompt haciendo unplug de jzrdip04_m3
alter pluggable database jzrdip04_m3 unplug into '/home/oracle/backups/jzrdip04_m3.xml';

prompt haciendo drop jzrdip04_m3
drop pluggable database jzrdip04_m3 keep datafiles;

prompt  Mover la PDB a su nuevo destino a /home/oracle/backups/jzrdip04_m3
prompt no olvidar actualizar las rutas en el xml
pause [Enter] para continuar

prompt deteniendo jzrdip04
!sh s-030-stop-cdb.sh jzrdip04 system4

prompt iniciando jzrdip03
!sh s-030-start-cdb.sh jzrdip03 system3

prompt ingresando a jzrdip03
conn sys/system3@jzrdip03 as sysdba
show con_id
show con_name

prompt  1. validar compatibilidad 
set serveroutput on
declare
  v_compatible boolean;
begin
  v_compatible := dbms_pdb.check_plug_compatibility(
    pdb_descr_file=>'/home/oracle/backups/jzrdip04_m3/jzrdip04_m3.xml',
    pdb_name=>'jzrdip04_m3'
  );
  if v_compatible then
    dbms_output.put_line('COMPATIBLE');
  else
    raise_application_error(-20001, 'PDB jzrdip04_m3 incompatible con jzrdip03');
  end if;
end;
/

pause Validar resultados [Enter] para continuar

prompt agregar la nueva PDB
create pluggable database jzrdip03_s1 using '/home/oracle/backups/jzrdip04_m3/jzrdip04_m3.xml'
  file_name_convert=(
    '/home/oracle/backups/jzrdip04_m3/',
    '/u01/app/oracle/oradata/JZRDIP03/jzrdip03_s1'
  );

prompt Abriendo PDB restaurada
alter pluggable database jzrdip03_s1 open read write;
show pdbs

pause Analizar resultados [Enter] para borrar backups!
!sudo rm -rf /home/oracle/backups/jzrdip03_s1
!sudo rm -rf /home/oracle/backups/jzrdip04_m3

spool off
exit;