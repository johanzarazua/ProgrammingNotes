--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 10/02/2023
--@Descripción: Creacion de una PDB from scratch

spool ./../../spools/m07-e03-01.txt replace
prompt 1. creando cdb a partir de SEED (from scratch)

prompt iniciando cdb jzrdip03
!sh s-030-start-cdb.sh jzrdip03 system3

prompt conectando como sys en jzrdip03
connect sys/system3@jzrdip03 as sysdba

prompt creando pdb jzrdip03_s3 a partir de SEED
-- parametro para indicar ruta para guardar datafiles de la nueva pdb
alter system set db_create_file_dest='/u01/app/oracle/oradata' scope=memory;

-- se utiliza OMF ya que no se especifican las demas rutas
create pluggable database jzrdip03_s3 admin user admin_s3 identified by admin_s3;

prompt cambiarse a /u01/app/oracle/oradata/JZRDIP03 como oracle 
pause Analizar datafiles [Enter] para continuar

prompt mostrando datos de la nueva CDB desde el DD.
col file_name format a80
select file_id, file_name from dba_data_files;

prompt mostrando datos de las pdbs
show pdbs

prompt mostrando datos de las PDBs (dba_pdbs)
select pdb_id, pdb_name, status from dba_pdbs;
pause Analizar [Enter] para continuar;

prompt modificando status de pdb
alter pluggable database jzrdip03_s3 open read write;

prompt accediendo a la pddb
alter session set container=jzrdip03_s3;
show con_id
show con_name

select file_id, file_name from dba_data_files;

pause [Enter] Para realizar limpieza
prompt cambiando a cdb$root
alter session set container=cdb$root;
--para eliminar pdb:
--    1. Cerrarla
--    2. hacer unplug
--    3. hacer drop
alter pluggable database jzrdip03_s3 close;

--dar permisos de escitura a oracle en la carpeta del script
!chmod 777 /unam-diplomado-bd/modulos/modulo-07/scripts/e-crear-pdbs
alter pluggable database jzrdip03_s3 unplug 
  into '/unam-diplomado-bd/modulos/modulo-07/scripts/e-crear-pdbs/metadata-jzrdip03_s3.xml';

pause Mostrando contenido de los metadatos [Enter] para ejecutar
!cat /unam-diplomado-bd/modulos/modulo-07/scripts/e-crear-pdbs/metadata-jzrdip03_s3.xml
pause Analizar xml [Enter] para continuar (se eliminaran los archivos)

drop pluggable database jzrdip03_s3 including datafiles;
!rm /unam-diplomado-bd/modulos/modulo-07/scripts/e-crear-pdbs/metadata-jzrdip03_s3.xml

exit