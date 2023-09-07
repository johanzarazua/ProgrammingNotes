connect user01/user01 

declare
  v_count number;
begin
  select count(*) into v_count from user_tables where table_name = 'TEST1';
  if v_count > 0 then
    execute immediate 'drop table test1';
  end if;
end;
/

create table test1(id number);