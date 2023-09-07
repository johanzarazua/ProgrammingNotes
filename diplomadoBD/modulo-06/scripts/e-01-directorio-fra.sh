# @Autor: Johan Axel Zarazua Ramirez 
# @Fecha creación: 20/enero/2023 
# @Descripción: Estructura de directorios para FRA

#!/bin/bash
echo "1. Creando directorio para la FRA"
mkdir -p /unam-diplomado-bd/fast-recovery-area

echo "2. Cambiando permisos del directorio"
cd /unam-diplomado-bd
chown oracle:oinstall fast-recovery-area
chmod 750 fast-recovery-area

echo "3. Mostrando estructura del directorio"
tree /unam-diplomado-bd/fast-recovery-area

exit