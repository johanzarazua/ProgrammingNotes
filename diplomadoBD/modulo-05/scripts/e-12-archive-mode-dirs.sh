# @Autor: Johan Axel Zarazua Ramirez 
# @Fecha creación: 07/enero/2023 
# @Descripción: Estructura de directorios para modo archive

#!/bin/bash

if [[ -d "/unam-diplomado-bd/disk-04/JZRDIP02" || 
  -d "/unam-diplomado-bd/disk-05/JZRDIP02" ]]; then
  echo "Directorio existente, se omite su creación";
  exit 1;
fi;

echo "Creando directorios para Archive Redo Logs"
mkdir -p  /unam-diplomado-bd/disk-04/JZRDIP02/archlogs;
mkdir -p  /unam-diplomado-bd/disk-05/JZRDIP02/archlogs;

cd /unam-diplomado-bd/disk-04

chown -R oracle:oinstall JZRDIP02/archlogs
chmod -R 750 JZRDIP02/archlogs

cd /unam-diplomado-bd/disk-05

chown -R oracle:oinstall JZRDIP02/archlogs
chmod -R 750 JZRDIP02/archlogs

echo "Mostrando estructura de directorios"
tree /unam-diplomado-bd/disk-04 /unam-diplomado-bd/disk-05
ls -l /unam-diplomado-bd/disk-04/JZRDIP02/archlogs;
ls -l /unam-diplomado-bd/disk-05/JZRDIP02/archlogs;