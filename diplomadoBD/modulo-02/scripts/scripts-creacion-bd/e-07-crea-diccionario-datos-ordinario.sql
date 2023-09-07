--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 24/septiembre/2022 
--@Descripción: Creacion del diccionario de dartos

prompt creando diccionario de datos

prompt ejecuntando scripts como sys
connect sys/system2 as sysdba
@?/rdbms/admin/catalog.sql
@?/rdbms/admin/catproc.sql
@?/rdbms/admin/utlrp.sql

prompt ejecuntando scripts como system
connect system/system2
@?/sqlplus/admin/pupbld.sql

prompt Listo !!!