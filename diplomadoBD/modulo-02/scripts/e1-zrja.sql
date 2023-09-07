--Primero conectamos con sysdba, desde el usuario adminitrador del s.o.
-- sqlplus sys as sydba 

connect sys as sysdba
create user usutestjzra quota 2G on users identified by usutestjzra;
create role role_admin;
grant create session, create table to role_admin with admin option;

grant role_admin to usutestjzra;
alter user usutestjzra password expire;

-- Este paso podria hacerso como usutestjzra o como sysdba, pero solo elegir una opcion 
-- ya que si se ejecutan las dos opciones maraca un error porque la tabla se repeteria

-- Opcion  sysdba
prompt cambiando a sysdba
connect sys as sysdba
create table usutestjzra.alumno( id number, nombre varchar2(100));
insert into usutestjzra.alumno(id, nombre) values(1, 'Luciano');
commit;

-- -- Opcion usuario usutestjzra
-- prompt cambiando al usuario usutestjzra
-- -- connect usutestjzra
-- -- create table alumno( id number, nombre varchar2);
-- -- insert into alumno(id, nombre) values(1, 'Luciano');
-- -- commit;

-- de igual manera hay dos formas para hacer esta instruccion.
-- Opcion sysdba
prompt cambiando a sysdba
connect sys as sysdba
select * from usutestjzra.alumno; 
-- mostra el registro 1 {id : 1, nombre : 'Luciano'}

-- Opcion usuario usutestjzra
prompt cambiando a usutestjzra
connect usutestjzra 
select * from alumno; 
-- mostra el registro 1 {id : 1, nombre : 'Luciano'}

prompt cambiando a sysdba
connect sys as sysdba
drop user usutestjzra cascade;
drop role role_admin;