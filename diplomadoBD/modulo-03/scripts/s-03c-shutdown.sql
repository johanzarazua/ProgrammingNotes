connect user01/user01

set serveroutput on

declare
  v_count number;
begin
  select count(*) into v_count from user_tables where table_name = 'TEST2';

  if v_count = 0 then
    execute immediate 'create table test2(id number)';
  else
    dbms_output.put_line('La tabla ya existe');
  end if;

end;
/

prompt insertando registro en test2 sin hacer commit
insert into test2 (id) values (100);

prompt mostrando los datos de las tablas
select * from test2;