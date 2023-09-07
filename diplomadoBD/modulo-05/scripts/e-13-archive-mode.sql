--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 13/01/2023
--@Descripción: Habilitacion del modo archive en la BD

Prompt Conectando como sysdba
connect sys/system2 as sysdba

Prompt 1. REalizando respaldo del spfile
create pfile from spfile;

Prompt Configurando parámetros
--Procesos ARCn
alter system set log_archive_max_processes = 5 scope = spfile;
--Formato del archivo
alter system set log_archive_format='arch_%t_%s_%r.arc' scope = spfile;
--Configuración de 2 copias
alter system set 
  log_archive_dest_1 = 'LOCATION=/unam-diplomado-bd/disk-04/JZRDIP02/archlogs MANDATORY' scope = spfile;
alter system set 
  log_archive_dest_2 = 'LOCATION=/unam-diplomado-bd/disk-05/JZRDIP02/archlogs' scope = spfile;

--Copias obligatorias
alter system set log_archive_min_succeed_dest=1 scope=spfile;

Prompt Confirmando cambios
show spparameter log_archive_max_processes
show spparameter log_archive_dest_1
show spparameter log_archive_dest_2
show spparameter log_archive_format
show spparameter log_archive_min_succeed_dest

Pause Revisar [enter]

Prompt 3. Reiniciando la isntancia en modo mount
--Se debería hacer un backup completo de la BD, antes como después de habilitar el modo archive
shutdown immediate
startup mount

Pause Cambiar a modo archive [enter]
alter database archivelog;

--Aquí se debería hacer un backup

Prompt 4. Abriendo BD en modo open
alter database open;

Prompt 5. Comprobando modo archive
archive log list

Prompt 6. Respaldando spfile
create pfile from spfile;

Prompt 7. Mostrando procesos ARCn 
!ps -ef | grep ora_arc