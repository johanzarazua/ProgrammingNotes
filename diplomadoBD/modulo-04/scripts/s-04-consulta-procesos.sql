--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 25/11/2022
--@Descripción: consulta de procesos

connect sys/system2 as sysdba

prompt mostrando el total de procesos extistentes en la isntancia
select count(*) total_procesos from v$process;

prompt mostrando el total de procesos que no son background
select count(*) no_background from v$process
  where background is null;

prompt mostrando el total de procesos que son background
select count(*) background from v$process
  where background = 1;

prompt mostrando los datos de la sesson de SQL Developer
select * from v$session where program = 'SQL Developer' and type = 'USER';

prompt Empleando el resultado anterior  para mostrar procesos asociados 
prompt a la session de SQL Developer
select p.* from v$process p, v$session s
where p.addr = s.paddr and
      s.program = 'SQL Developer' and 
      s.type = 'USER';
      
prompt mostrando datos de monitoreo
select h.* from v$active_session_history h, v$session s
where h.session_id = s.sid and 
      s.program = 'SQL Developer' and 
      s.type = 'USER';