--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 21/01/2023
--@Descripción: Uso de Flashback table

define userlogon='user06/user06'

spool ./../spools/e-05.txt replace

Prompt 1. Conectando con el usuario user06
conn &userlogon

Prompt Creando la tabla venta
create table venta(
  idVenta number, 
  monto number(12)
);

exec dbms_lock.sleep(5);

Prompt 2. Configurando la tabla para regresarla ern el tiempo
alter table venta enable row movement;

Prompt 3. Tomando el scn actual y el tiempo
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora1,
  dbms_flashback.get_system_change_number() scn1
  from dual;

exec dbms_lock.sleep(5);

Prompt 4. Agregando el primer registro a la tabla
Prompt registro 1
insert into venta values(1, 1300);
commit;
select * from venta;

exec dbms_lock.sleep(5);

Prompt 5. Tomando el scn actual y el tiempo
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora2,
  dbms_flashback.get_system_change_number() scn2
  from dual;

Prompt 6. Agregando el segundo registro a la tabla
Prompt registro 2
insert into venta values(2, 1500);
commit;
select * from venta;

exec dbms_lock.sleep(5);

Prompt Tomando el scn actual y el tiempo
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora3,
  dbms_flashback.get_system_change_number() scn3
  from dual;

Prompt Agregando el tercer registro a la tabla
Prompt registro 3
insert into venta values(3, 500);
commit;
select * from venta;

exec dbms_lock.sleep(5);

Prompt Tomando el scn actual y el tiempo
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora4,
  dbms_flashback.get_system_change_number() scn4
  from dual;

Prompt 7. Mostrar el contenido actual de la tabla
select * from venta;

Prompt Elimianndo el contenido de la tabla
delete from venta;
commit;

Prompt Mostrando los cambios
select * from venta;

exec dbms_lock.sleep(5);

Prompt 8. Tomando el scn actual y el tiempo
select to_char(sysdate, 'dd-mm-yyyy hh24:mi:ss') fechaHora5,
  dbms_flashback.get_system_change_number() scn5
  from dual;

Prompt 9. Restaurando el contenido de la tabla en algún punto 
Prompt Con scn
flashback table venta to scn &scn;
select * from venta;

Prompt con fechaHora
flashback table venta to timestamp to_timestamp('&fechaHora', 'dd-mm-yyyy hh24:mi:ss');
select * from venta;

Prompt Mostrando el contenido de la tabla venta
select * from venta;

exit;