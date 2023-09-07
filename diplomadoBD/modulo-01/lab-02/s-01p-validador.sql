--@Autor(es):       Jorge Rodríguez
--@Fecha creación:  dd/mm/yyyy
--@Descripción:     Validación de instancia.

Prompt Proporcionar el password de SYS
connect sys as sysdba
set serveroutput on

@s-00-funciones-validacion.plb

create or replace procedure spv_valida_datos_instancia is
  cursor cur_consulta is
    select instance_name,host_name,version,version_full,
      startup_time,con_id,instance_mode,edition,
      lower(global_name) as global_name
      from v$instance,global_name;
begin
  for r in cur_consulta loop
    spv_print_ok('host name ....................'||r.host_name);
    spv_print_ok('startup ......................'
      ||to_char(r.startup_time,'dd/mm/yyyy hh24:mi:ss'));
    spv_print_ok('Instance name ................'||r.instance_name);
    spv_print_ok('con id .......................'||r.con_id);
    spv_print_ok('instance mode ................'||r.instance_mode);
    spv_print_ok('edition ......................'||r.edition);

    --valida nombre global de la instancia
    if  instr(r.global_name,'dip01.fi.unam',1,1) > 0 or
        instr(r.global_name,'diplo.fi.unam',1,1) > 0  then
      spv_print_ok('Global name ..................'||r.global_name);
    else
      spv_throw_error('Nombre global de la BD incorrecto. Obtenido: '
        ||r.global_name||', esperado: <iniciales>dip01.fi.unam');
    end if;
    
    --versión
    spv_assert('19.3.0.0.0' = r.version_full,'19.3.0.0.0',r.version_full,
      'Versión de la BD incorrecta');
    spv_print_ok('version ......................'||r.version);
    spv_print_ok('version  full.................'||r.version_full);
    --verifica que no se haya configurado un container.

    spv_assert(0 = r.con_id,0,r.con_id,'Valor incorrecto para con_id: '
      ||r.version_full
      ||' Notificar este error la profesor ya que la instalación se'
      ||' realizó de manera incorrecta. La base se creó en modo CDB '
      ||', se esperaba 0'
    );
    spv_print_ok('Id de contenedor...............'||r.con_id);
  end loop;
end;
/
show errors
exec spv_print_header
exec spv_valida_datos_instancia

Prompt Eliminando procedimientos de validación
exec spv_remove_procedures

Prompt Listo!
exit