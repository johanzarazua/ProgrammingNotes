--@Autor: Johan Axel Zarazua Ramirez 
--@Fecha creación: 09/septiembre/2022 
--@Descripción: Administración de object privileges

Prompt Conectando como sys dba
conn sys/system1 as sysdba

Prompt Creando usuarios
create user user01 identified by user01 quota unlimited on users;
create user guest01 identified by guest01 quota unlimited on users;

Prompt Otorgando privilegios de sistema
grant create session, create table to user01;
grant create session to guest01;


Prompt Creando usuario guest02 con privilegios
grant create session to guest02 identified by guest02;
alter user guest02 quota 10M on users;

Prompt permitir a guest02 la posibilidad de otorgar privilegios de objeto a cualquier usuario
grant grant any object privilege to guest02;

Promp Conectando con user01
connect user01/user01

Prompt Creando tabla prueba 
create table test(id number);
insert into test (id) values (1);
commit; 

Prompt Conectando como guest01
connect guest01/guest01

Prompt intentar consultar datos de la tabla test, se espera error
pause ¿Que sucedera si se intenta acceder a user01.test? [enter]
select * from user01.test;

Prompt Otorgando prvilegio de objeto (select) a guest01
Prompt Conectando como user01
connect user01/user01

grant select on test to guest01;
-- SYS tambien puede otorgar este privilegio => grant select on user01.test to guest01

Prompt Conectando como guest01
connect guest01/guest01

Prompt intentar consultar datos de la tabla test para validar acceso
pause ¿Que sucedera ahora, guest01 podra acceder a la tabla test? [enter]
select * from user01.test;


Prompt Conectando como guest02
connect guest02/guest02

Prompt dando privilegios de insercion a guest01
grant insert on user01.test to guest01;

Prompt Conectando como guest01
connect guest01/guest01

Prompt intentar insertar datos de la tabla test para validar acceso
pause ¿Que sucedera ahora, guest01 podra insertar a la tabla test? [enter]
insert into user01.test (id) values (2);

select * from user01.test;


Prompt Realizando limpieza
connect sys/system1 as sysdba
drop user user01 cascade;
drop user guest01;
drop user guest02;

disconnect