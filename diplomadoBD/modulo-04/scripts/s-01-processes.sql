--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 11/11/2022
--@Descripción: Procesos relacionadoss a una instancia

prompt mostrando user processes con instancia detenida
!ps -ef | grep -e sqlplus -e jzrdip02 | grep -v grep

prompt autenticando como sys
connect sys/system2 as sysdba
prompt mostrando nuevamente user processes
pause Que pasara? [Enter] para continuar
-- Aparece un server process de la conexion con sys
!ps -ef | grep -e sqlplus -e jzrdip02 | grep -v grep

prompt mostrando proceso del listener
!ps -ef | grep -e sqlplus -e jzrdip02 -e LISTENER | grep -v grep
pause [Enter] para continuar

prompt levantando la instancia en modo nomount
startup nomount

prompt mostrando proceso nuevamente, instancia en modo nomount 
pause Que pasara? [Enter] para continuar
-- Se muestran todos los proceso de background
!ps -ef | grep -e sqlplus -e jzrdip02 -e LISTENER | grep -v grep

prompt abriendo BD
alter database mount;
alter database open;

prompt cerrando sesion
disconnect

prompt conectando como sysdba
connect sys/system2 as sysdba

prompt mostrando los precesos de la nueva conexion 
!ps -ef | grep -e sqlplus -e "LOCAL=YES" -e LISTENER | grep -v grep

prompt Analizar respuetas, anotar IDs de procesos y compararlos con los obtenidos en SQL Developer
-- sp. 8922
-- up. 8389