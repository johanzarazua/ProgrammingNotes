--primero nos conectamos como sysdba, usando el usuario administrador del s.o.

connect sys as sysdba

create user user_test identified by test1234 quota unlimited on users;
grant create session, create table to user_test;
grant sysdba to user_test;

connect user_test/test1234
show user
create table tabla1( id number);
insert into tabla1(id) values(1);
commit;
 -- Nos permitira hacer el select y muestra {id : 1}
select * from tabla1;  


connect user_test/test1234 as sysdba
select * from user_test.tabla1;  

prompt Se podra consultar la tabla ya que conectamos con el privilegio sysdba, y nos muestra el registro con id 1

connect sys as sysdba
drop user user_test cascade;