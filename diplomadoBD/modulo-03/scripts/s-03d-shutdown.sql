connect user01/user01

set serveroutput on

declare
  v_count number;
begin
  select count(*) into v_count from user_tables where table_name = 'TEST3';

  if v_count = 0 then
    execute immediate 'create table test3(id number)';
  else
    dbms_output.put_line('La tabla ya existe');
  end if;

end;
/

prompt insertando registro en test3 con commit
insert into test3 (id) values (100);
commit;

prompt mostrando los datos de las tablas
select * from test3;