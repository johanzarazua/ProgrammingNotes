# @Autor: Johan Axel Zarazua Ramirez 
# @Fecha creación: 29/01/2023 
# @Descripción: Estructura de directorios para datafiles

#!/bin/bash

if [[ -d "/unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/" ]]; then
  echo "Los directorio /unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/ ya existen, se omite su creación";
else
  echo "Creando directorio /unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/"
  mkdir -p /unam-diplomado-bd/u21/app/oracle/oradata/JZRDIP02/
  chown -R oracle:oinstall /unam-diplomado-bd/u21
  chmod -R 750 /unam-diplomado-bd/u21
  cd /
fi;

if [[ -d "/unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/" ]]; then
  echo "Los directorio /unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/ ya existen, se omite su creación";
else
  echo "Creando directorio /unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/"
  mkdir -p /unam-diplomado-bd/u22/app/oracle/oradata/JZRDIP02/
  chown -R oracle:oinstall /unam-diplomado-bd/u22
  chmod -R 750 /unam-diplomado-bd/u22
  cd /
fi;

if [[ -d "/unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/" ]]; then
  echo "Los directorio /unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/ ya existen, se omite su creación";
else
  echo "Creando directorio /unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/"
  mkdir -p /unam-diplomado-bd/u23/app/oracle/oradata/JZRDIP02/
  chown -R oracle:oinstall /unam-diplomado-bd/u23
  chmod -R 750 /unam-diplomado-bd/u23
  cd /
fi;

if [[ -d "/unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/" ]]; then
  echo "Los directorio /unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/ ya existen, se omite su creación";
else
  echo "Creando directorio /unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/"
  mkdir -p /unam-diplomado-bd/u24/app/oracle/oradata/JZRDIP02/
  chown -R oracle:oinstall /unam-diplomado-bd/u24
  chmod -R 750 /unam-diplomado-bd/u24
  cd /
fi;

if [[ -d "/unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/" ]]; then
  echo "Los directorio /unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/ ya existen, se omite su creación";
else
  echo "Creando directorio /unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/"
  mkdir -p /unam-diplomado-bd/u25/app/oracle/oradata/JZRDIP02/
  chown -R oracle:oinstall /unam-diplomado-bd/u25
  chmod -R 750 /unam-diplomado-bd/u25
  cd /
fi;

if [[ -d "/unam-diplomado-bd/u31/app/oracle/oradata/JZRDIP02/" ]]; then
  echo "Los directorio /unam-diplomado-bd/u31/app/oracle/oradata/JZRDIP02/ ya existen, se omite su creación";
else
  echo "Creando directorio /unam-diplomado-bd/u31/app/oracle/oradata/JZRDIP02/"
  mkdir -p /unam-diplomado-bd/u31/app/oracle/oradata/JZRDIP02/
  chown -R oracle:oinstall /unam-diplomado-bd/u31
  chmod -R 750 /unam-diplomado-bd/u31
  cd /
fi;

if [[ -d "/tmp/dip/911" ]]; then
  echo "Los directorio /tmp/dip/911 ya existen, se omite su creación";
else
  echo "Creando directorio /tmp/dip/911"
  mkdir -p /tmp/dip/911
  chmod -R 775 /tmp/dip/911
  cd /
fi;

if [[ -f "/tmp/dip/911/calls-911-50m.csv" ]]; then
  echo "El archivo ya se encunetra en la ubicaicon";
else
  echo "Colocando el archivo ya en la ubicaicon";

  cp /home/johanzr/Documents/calls-911-50m.csv /tmp/dip/911/
fi;