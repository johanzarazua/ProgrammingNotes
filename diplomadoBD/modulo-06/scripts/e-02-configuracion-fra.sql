--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 20/01/2023
--@Descripción: Configuracion de FRA

set verify off
define syslogon = 'sys/system2 as sysdba'

spool ./../spools/e-02-configuracion-fra.txt replace

prompt Conectando como sys
connect &syslogon

prompt 1. Verificando el parametro DB_RECOVERY
show parameter db_recovery;

prompt 2. Verificando modo archive log
archive log list;

prompt 3. Especificar tamaño y ubicacion de la FRA
alter system set db_recovery_file_dest_size = 20G scope = both;
alter system set db_recovery_file_dest = '/unam-diplomado-bd/fast-recovery-area' scope = both;

prompt 4. Reinicnando instancia en modo mount
prompt Deteniendo instancia
shutdown immediate
prompt 
prompt Inicnando en modo mount
startup mount

prompt 5. Configurando el periodo de retencion para flashback (24h)
alter system set db_flashback_retention_target = 1440 scope = both;

prompt 6. Habilitando el modo flashback
alter database flashback on;

prompt 7. Abriendo BD
alter database open ;

prompt 8. Verificando el modo flashback activo
select flashback_on from v$database;

prompt 9. Mostrando tiempo de retencion configurado
show parameter undo_ret;

prompt Modificando tiempo de retencion de datos undo
alter system set undo_retention = 1800 scope = both;

prompt Mostrando nuevamente tiempo de retencion configurado
show parameter undo_ret;

prompt Listo!!!!
exit