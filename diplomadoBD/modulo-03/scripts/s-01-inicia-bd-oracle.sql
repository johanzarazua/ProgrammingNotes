--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 21/10/2022
--@Descripción: Simulacion de la perdida de algunos archivos de la BD, posteriormente se iniciaria la BD pasando por sus diferentes estados para identificar que archivos utiliza en cada etapa.s

prompt connectando como sysdba
connect sys/system2 as sysdba

prompt
prompt deteniendo instancia
shutdown immediate

prompt creando carpeta de respaldos
define backup_dir='/home/oracle/backups/modulo-03'
!mkdir -p &backup_dir

prompt moviendo archivos a respaldo seguro (simular perdida)
prompt moviendo spfile y pfile
!mv $ORACLE_HOME/dbs/spfilejzrdip02.ora &backup_dir
!mv $ORACLE_HOME/dbs/initjzrdip02.ora &backup_dir

prompt moviendo un solo archivo de control
!mv /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/control01.ctl &backup_dir

prompt moviendo todos los redo logs
!mv /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo01a.log &backup_dir
!mv /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo02a.log &backup_dir
!mv /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/redo03a.log &backup_dir

!mv /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo01b.log &backup_dir
!mv /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo02b.log &backup_dir
!mv /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/redo03b.log &backup_dir

!mv /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo01c.log &backup_dir
!mv /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo02c.log &backup_dir
!mv /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/redo03c.log &backup_dir

prompt moviendo datafile
!mv $ORACLE_BASE/oradata/JZRDIP02/system01.dbf &backup_dir
!mv $ORACLE_BASE/oradata/JZRDIP02/users01.dbf &backup_dir

prompt mostrando archivos en el directorio de respaldo.
!ls -la &backup_dir

pause verificar que los archivos se hayan respaldado [enter para continuar]

prompt iniciando instancia en modo nomount, se espera error debido a que no encontrara algun archivo de parametros
pause Que sucedera? [enter para continuar]
startup nomount

pause [enter para continuar con la solucion]
prompt restaurando spfile y pfile
!mv &backup_dir/spfilejzrdip02.ora $ORACLE_HOME/dbs/
!mv &backup_dir/initjzrdip02.ora $ORACLE_HOME/dbs/

prompt iniciando instancia en modo nomount, se soluciona el error
pause Que sucedera? [enter para continuar]
startup nomount

prompt cambiando base a estado mount, se espera error debido a que no encuetra el archivo de control
pause Que sucedera? [enter para continuar]
alter database mount;

pause [enter para continuar con la solucion]
prompt recuperando archivo de control 
!mv &backup_dir/control01.ctl /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/

prompt cambiando base a estado mount, se soluciona el error
pause Que sucedera? [enter para continuar]
alter database mount;

prompt pasandoa modo open, se espera error ya que no encuentra los datafiles
pause Que sucedera? [enter para continuar]
alter database open;

pause [enter para continuar con la solucion]
prompt restaurando datafile para tablespace system
!mv &backup_dir/system01.dbf $ORACLE_BASE/oradata/JZRDIP02/

prompt pasandoa modo open, se espera error, aun le falta encontrar un datafile
pause Que sucedera? [enter para continuar]
alter database open;

pause [enter para continuar con la solucion]
prompt restaurando datafile para tablespace users
!mv &backup_dir/users01.dbf $ORACLE_BASE/oradata/JZRDIP02/

prompt pasandoa modo open, se espera error, en este caso marca un error ya que no va a encontrar ningun redo log
pause Que sucedera? [enter para continuar]
alter database open;

-- en el caso de borrar solo un redo log por grupo la base puede levantar, mientras minimo exista un redo log por grupo esto succedera
-- para poder hacer que falle el levnatamiento de la instancia se deben eliminar todos los redo logs de un grupo
-- al no saber que grupo se esta usando lo correcto seria eliminar todos los grupos
pause [enter para continuar con la solucion]
prompt restaurando redo logs
!mv &backup_dir/redo01a.log /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/ 
!mv &backup_dir/redo02a.log /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/ 
!mv &backup_dir/redo03a.log /unam-diplomado-bd/disk-01/app/oracle/oradata/JZRDIP02/

!mv &backup_dir/redo01b.log /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/ 
!mv &backup_dir/redo02b.log /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/ 
!mv &backup_dir/redo03b.log /unam-diplomado-bd/disk-02/app/oracle/oradata/JZRDIP02/ 

!mv &backup_dir/redo01c.log /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/ 
!mv &backup_dir/redo02c.log /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/ 
!mv &backup_dir/redo03c.log /unam-diplomado-bd/disk-03/app/oracle/oradata/JZRDIP02/ 

prompt pasandoa modo open, se soluciona el error
connect sys/system2 as sysdba
startup open;

prompt mostrando status
select status from v$instance;

prompt Listo!!!!
exit