--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 21/10/2022
--@Descripción: Inicia la BD en modo restringido y read only

prompt conectando como sysdba
connect sys/system2 as sysdba

prompt deteniendo la instancia (en caso de estar inicada)
shutdown immediate

prompt
prompt iniciando instancia en modo open
startup open;

prompt cambiando a modo restringido
alter system enable restricted session;

prompt creando user01 y asignando privilegios
create user user01 identified by user01 quota unlimited on users;
grant create session, create table to user01;

prompt autenticando como user01, se espera que no nos permita ingresar debido a que la base esta en modo restringido y solo los usuarios con el privilegio restricted session pueden ingresar
pause Que sucedera? [enter para continuar]
connect user01/user01

prompt autenticando como sysdba
connect sys/system2 as sysdba
prompt otorrgando privilegio a user01 para poder ingresar en modo restringido
grant restricted session to user01;

prompt autenticando como user01, se espera poder ingresar ya que se le dio el privilegio necesario a user01
pause Que sucedera? [enter para continuar]
connect user01/user01

prompt autenticando como sysdba
connect sys/system2 as sysdba
prompt desahabilitando modo restringido
alter system disable restricted session;

-- para pasar a modo read only, se debe detener la DB. 
-- antes de pasar a este modo se debe activa/suspedner esto evita tener que cerrarla, los usuarios no deben desconectarse
prompt deteniendo base de datos
shutdown immediate

prompt
prompt abriendo base de datos en modo read only
startup open read only;

prompt autenticando como user01
connect user01/user01
prompt creando tabla de prueba, se espera error ya que la base esta en modo read only y esto impide que se haga algun cambio en datafiles y redologs
pause Que sucedera? [enter para continuar]
create table test(id number);

prompt autenticando como sysdba
connect sys/system2 as sysdba
prompt regresando a modo read write
shutdown immediate
prompt abriendo base de datos en modo read write
startup open read write;

prompt realizando limpieza
drop user user01 cascade;
prompt listo!!!
exit