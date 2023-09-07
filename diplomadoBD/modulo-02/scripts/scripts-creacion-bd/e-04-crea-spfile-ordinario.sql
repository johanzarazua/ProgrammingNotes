--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 23/septiembre/2022 
--@Descripción: Creacion de SPFILE

prompt autenticando como sysdba empleando archivo de passwords

connect sys/hola1234* as sysdba

prompt traer al mundo una nueva instancia
startup nomount


prompt creando spfile a partir del pfile creado manualmente 
create spfile from pfile;

prompt validanod existencia
!ls -l $ORACLE_HOME/dbs/spfilejzrdip02.ora