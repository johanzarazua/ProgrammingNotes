--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 05/11/2022
--@Descripción: Matar sesiones de usurioes conectados en la BD

connect sys/system2 as sysdba

prompt mostrando status de inactividad
-- muestra inactivando
select active_state from v$instance;

prompt elimiando sesiones que impiden inactivar BD
pause Cuantas sesiones deberan terminarse? [Enter] para continuar
-- solo se espera cerrar la sesion en T2 porque la de T1 no esta ejecutando ninguna sentencia
set serveroutput on

declare
  cursor cur_sesiones is 
    select s.sid, s.serial#, s.username
      from v$session s, v$blocking_quiesce b
      where s.sid = b.sid;

begin
  for r in cur_sesiones loop
    dbms_output.put_line('Cerrando sesion para el usuario '|| r.username);
    execute immediate 'alter system kill session '''||r.sid||','||r.serial#||'''';
  end loop;

end;
/