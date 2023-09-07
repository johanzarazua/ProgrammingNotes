prompt Realizando lecturas repetibles.
define test_user = 'JOHAN05'
define test_user_logon = 'JOHAN05/JOHAN05'

connect &test_user_logon

prompt habilitando permismos de aislamiento - lecturas repetibles serializables
set transaction isolation level serializable name 'T1-RC';

prompt realizanso consultas
select count(*) from random_str_2;
select count(*) from random_str_2 
  where cadena like 'A%'
    or cadena like 'Z%'
    or cadena like 'M%';