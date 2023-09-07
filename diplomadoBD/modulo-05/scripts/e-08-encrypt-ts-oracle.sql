define p_user = 'JOHAN05'

connect sys/system2 as sysdba

prompt creando y abriendo wallet
alter system set encryption key identified by "wallet_password";

prompt creando nuevo TS
create tablespace m05_encrypted_ts
  datafile '/u01/app/oracle/oradata/JZRDIP02/m05_encrypted_ts_01.dbf' size 10M
  autoextend on next 64k
  encryption using 'aes256'
  default storage(encrypt)
;

prompt otorgando quota
alter user &p_user quota unlimited on m05_encrypted_ts;

prompt comprobando configuracion de los ts
select tablespace_name, encrypted from dba_tablespaces;

pause [Enter] para continuar

prompt conectando como johan05
connect &p_user/&p_user

prompt creaando tabla mensaje_seguro en ts m05_encrypted_ts
create table mensaje_seguro(
  id  number,
  mensaje varchar2(20)
) tablespace m05_encrypted_ts;

prompt insertando registros
insert into mensaje_seguro (id, mensaje) values (1, 'mensaje 1');
insert into mensaje_seguro (id, mensaje) values (2, 'mensaje 2');
commit;

prompt consultando datos
select * from mensaje_seguro;

prompt creaando tabla mensaje_inseguro en ts users
create table mensaje_inseguro(
  id  number,
  mensaje varchar2(20)
);

prompt insertando registros
insert into mensaje_inseguro (id, mensaje) values (1, 'mensaje 1');
insert into mensaje_inseguro (id, mensaje) values (2, 'mensaje 2');
commit;

prompt consultando datos
select * from mensaje_inseguro;


prompt forzando sincronizacion (usando sys)
connect sys/system2 as sysdba
alter system checkpoint;

pause [Enter] para realizar la busqueda del texto en el TS cifrados
!strings /u01/app/oracle/oradata/JZRDIP02/m05_encrypted_ts_01.dbf | grep "mensaje"

--reiniciar y volver a mostrar los datos
pause Reiniciando instancia [Enter] para continuar
shutdown immediate
startup

prompt consultando datos nuevamente
connect &p_user/&p_user

select * from mensaje_seguro;

pause [Enter] para continuar y corregir el problema

connect sys/system2 as sysdba

prompt abriendo wallet
alter system set encryption wallet open identified by "wallet_password";

prompt mostrando datos nuevamente
connect &p_user/&p_user

select * from mensaje_seguro;

pause [Enter] para realizar limpieza

drop table mensaje_seguro;
drop table mensaje_inseguro;

connect sys/system2 as sysdba
drop tablespace m05_encrypted_ts including contents and datafiles;

prompt Listo!
exit