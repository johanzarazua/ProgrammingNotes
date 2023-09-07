spool ./../spools/t-01-alerta.txt replace

conn sys as sysdba

prompt configurando alerta
begin
-- se generara una alerta por usuarios bloqueados.
-- generara un warning a los 2 bloqueados y un critico cuando sea mayor o igual a 3
  dbms_server_alert.set_threshold(
    metrics_id              => DBMS_SERVER_ALERT.BLOCKED_USERS,
    warning_operator        => DBMS_SERVER_ALERT.OPERATOR_EQ,
    warning_value           => '2',
    critical_operator       => DBMS_SERVER_ALERT.OPERATOR_GE,
    critical_value          => '3',
    observation_period      => 1,
    consecutive_occurrences => 1,
    instance_name           => null,
    object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_SESSION,
    object_name             => null
  ); 
end;
/

pause Realizar las acciones correspondientes para generar alerta, [Enter] para continuar

prompt realizando consulta
col owner format a30
col object_name format a30
col reason format a50
select sequence_id,owner,object_name,reason,creation_time,time_suggested from DBA_OUTSTANDING_ALERTS;

prompt regresando valores de alwerta a su valor por default
begin
  dbms_server_alert.set_threshold(
    metrics_id              => DBMS_SERVER_ALERT.BLOCKED_USERS,
    warning_operator        => DBMS_SERVER_ALERT.OPERATOR_EQ,
    warning_value           => null,
    critical_operator       => DBMS_SERVER_ALERT.OPERATOR_GE,
    critical_value          => null,
    observation_period      => 1,
    consecutive_occurrences => 1,
    instance_name           => null,
    object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_SESSION,
    object_name             => null
  ); 
end;
/

exit