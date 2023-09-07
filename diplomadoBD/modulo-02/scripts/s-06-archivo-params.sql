--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 10/septiembre/2022 
--@Descripción: Crear archivos de parámetros

Prompt conectando como sysdba
connect sys/system1 as sysdba

Prompt creando pfile a partir de un spfile
create pfile='/tmp/pfile-spfile.ora' from spfile;

Prompt creando spfile a partir de la instancia (debe estar levantada)
create pfile='/tmp/pfile-memory.ora' from memory;

Prompt cambiando permisos en S.O del archivo, proporcionar password
!sudo chmod 777 /tmp/pfile-memory.ora

pause Revisando archivos [Enter] para continuar

Prompt agregando parametro al pfile
!echo "nls_date_format=dd/mm/yyyy hh24:mi:ss" >> /tmp/pfile-memory.ora

shutdown immediate

Prompt iniciando instancia utilizando pfile
startup pfile='/tmp/pfile-memory.ora'

Prompt comprobando el valor del paramatro nls_date_format
select sysdate from dual;


Prompt modificando paramatro nls_date_format en el spfile, se espera error.
pause Que pasara?
--no se podra cambiar el parametro porque se inicio la instancia desde un pfile
alter system nls_date_format='dd/mm/yyyy' scope=spfile;