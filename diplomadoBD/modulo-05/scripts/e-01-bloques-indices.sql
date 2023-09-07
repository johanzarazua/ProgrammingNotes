--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 26/11/2022
--@Descripción: Creacion de un indice B tree

prompt conectando como sys
connect sys/system2 as sysdba
whenever sqlerror exit rollback;
set serveroutput on
define p_user = 'JOHAN05'

declare
  v_count number;
begin
  select count(*) into v_count
    from all_users where username = '&p_user';
  
  if v_count > 0 then
    dbms_output.put_line('Eliminando al usuario &p_user');
    execute immediate 'drop user &p_user cascade';
  else
    dbms_output.put_line('El usuario &p_user no existe');
  end if;

end;
/

prompt creando el usuario JOHAN05
create user &p_user identified by &p_user quota unlimited on users;
grant create session, create table to &p_user;

prompt conectando como JOHAN05
connect &p_user/&p_user

prompt creando tabla
create table t01_id (
  id number(10,0) constraint t01_id_pk primary key
);

prompt insertando primer registro
insert into t01_id (id) values (1);

prompt mostrando informacion del indice
col table_name format a20
select index_type, table_name, uniqueness, tablespace_name, status, blevel, distinct_keys, leaf_blocks
from user_indexes
where index_name = 'T01_ID_PK';

pause Analizar resulatado, [Enter] para continuar

prompt recolectando estadisticas 
begin
  dbms_stats.gather_index_stats(ownname => '&p_user', indname => 'T01_ID_PK');
end;
/

prompt mostrando informacion del indice despues de obtener estadisticas
col table_name format a20
select index_type, table_name, uniqueness, tablespace_name, status, blevel, distinct_keys, leaf_blocks
from user_indexes
where index_name = 'T01_ID_PK';

pause Analizar resulatado, [Enter] para continuar y realizar carga de datos

begin
  for v_index in 2..1000000 loop
    execute immediate 'insert into t01_id(id) values(:ph1)' using v_index;
    -- insert into t01_id (id) values (v_index);
  end loop;
end;
/

prompt recolectando estadisticas 
begin
  dbms_stats.gather_index_stats(ownname => '&p_user', indname => 'T01_ID_PK');
end;
/

prompt mostrando informacion del indice despues de la carga
col table_name format a20
select index_type, table_name, uniqueness, tablespace_name, status, blevel, distinct_keys, leaf_blocks
from user_indexes
where index_name = 'T01_ID_PK';

pause Analizar resulatado, [Enter] para continuar
exit