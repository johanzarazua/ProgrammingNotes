--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 04/11/2022
--@Descripción: Creacion  y ejecucion de jobs

prompt conectando como sysdba
connect sys/system2 as sysdba
define p_num_workers=3

prompt registrando jobs para cragar datos
set serveroutput on
declare
  v_num_workers number := &p_num_workers;
  v_usr_prefix varchar2(20) := 'WORKER_M03_';
  v_start_date date;
begin
  -- iniciar la tarea en los proximos 20 segundos
  v_start_date := sysdate + 20/24/60/60;

  for i in 1..v_num_workers loop
    dbms_output.put_line('Creando job para worker '||i);
    dbms_scheduler.create_job(
      job_name    =>    v_usr_prefix||i||'.job_generate_data',
      job_type    =>    'STORED_PROCEDURE',
      job_action  =>    v_usr_prefix||i||'.sp_generate_data',
      start_date  =>    v_start_date,
      enabled     =>    true
    );
  end loop;
end;
/

Prompt esperando a que los jobs terminen - carga de datos
declare
  v_count number;
begin 
  loop 
    select count(*) into v_count from dba_scheduler_jobs
    where owner like 'WORKER_M03%'
    and job_name ='JOB_GENERATE_DATA'
    and state in ('RUNNING','SCHEDULED');

    if v_count > 0 then 
      dbms_session.sleep(30);
    else
      dbms_output.put_line('0 jobs pendientes');
      exit;
    end if;
  end loop;
end;
/

pause carga concuida, [enter] para iniciar con el analisis
declare
  v_num_workers number := &p_num_workers;
  v_usr_prefix varchar2(20) := 'WORKER_M03_';
  v_start_date date;
begin
  -- iniciar la tarea en los proximos 20 segundos
  v_start_date := sysdate + 20/24/60/60;

  for i in 1..v_num_workers loop
    dbms_output.put_line('Creando job para worker '||i);
    dbms_scheduler.create_job(
      job_name    =>    v_usr_prefix||i||'.job_process_data',
      job_type    =>    'STORED_PROCEDURE',
      job_action  =>    v_usr_prefix||i||'.sp_process_data',
      start_date  =>    v_start_date,
      enabled     =>    true
    );
  end loop;
end;
/

Prompt esperando a que los jobs terminen - procesamiento de datos
declare
  v_count number;
begin 
  loop 
    select count(*) into v_count from dba_scheduler_jobs
    where owner like 'WORKER_M03%'
    and job_name ='JOB_PROCESS_DATA'
    and state in ('RUNNING','SCHEDULED');
    if v_count > 0 then 
      dbms_session.sleep(30);
    else
      dbms_output.put_line('0 jobs pendientes');
      exit;
    end if;
  end loop;
end;
/

prompt analisis concluido, mostrando resultados
prompt worker_m03_1
select * from worker_m03_1.total_results;

prompt worker_m03_2
select * from worker_m03_2.total_results;

prompt worker_m03_3
select * from worker_m03_3.total_results;

prompt guardando un nuevo registro para visualizar cambios de memoria.
@s-14-monitor-mem.sql