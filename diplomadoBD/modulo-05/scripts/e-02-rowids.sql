--@Autor: Johan Axel Zarazua Ramirez
--@Fecha creación: 26/11/2022
--@Descripción: Consulta del contenidos de un rowid

define p_user = 'JOHAN05'

connect &p_user/&p_user
whenever sqlerror exit rollback;

prompt mostrando los primeros 10 registros con su row id
--se usa subconsulta para primero generar el ordenamiento, y posterior se toman los registros
--que queremos con el rownum
select row_id, id from(
  select rowid as row_id, id from t01_id order by id
) where rownum <= 10;

prompt mostrando segmentos 
select substr(rowid, 1, 6) segmentos, count(*) total_registros
from t01_id
group by substr(rowid, 1, 6);

pause Analizar resultados, [Enter] para continuar

prompt mostrando datafile y registros asignados 
select substr(rowid, 7, 3) datafile, count(*) total_registros
from t01_id
group by substr(rowid, 7, 3);

pause Analizar resulatado, [Enter] para continuar

prompt mostrando bloque de datos y registros incluidos
select substr(rowid, 10, 6) bloques, count(*) total_registros
from t01_id
group by substr(rowid, 10, 6);

exit