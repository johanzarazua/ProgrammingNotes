# --@Autor: Johan Axel Zarazua Ramirez 
# --@Fecha creación: 23/septiembre/2022 
# --@Descripción: Creacion de directorios
#!/bin/bash
echo "Creando directorios para la nueva BD"

echo "Creando directorios para datafiles"

dirDataFiles="/u01/app/oracle/oradata/JZRDIP02"

if [ -d "${dirDataFiles}" ]; then
  read -p "El directorio no esta vacio [Enter] para borrar, Ctrl-C cancelar"
  rm -rf "${dirDataFiles}"/*
fi;

echo "Cambiando dueño y permisos"
mkdir -p "${dirDataFiles}"
chown oracle:oinstall "${dirDataFiles}"
chmod 750 "${dirDataFiles}"

echo "Creando directorios para Redo Logs y Control files"

pMontaje01="/unam-diplomado-bd/disk-01"
pMontaje02="/unam-diplomado-bd/disk-02"
pMontaje03="/unam-diplomado-bd/disk-03"

path="app/oracle/oradata/JZRDIP02"

if [[ -d "${pMontaje01}/${path}" || -d "${pMontaje02}/${path}" || -d "${pMontaje03}/${path}" ]]; then
  read -p "Se encontraron diretorios, [Enter] para borrar, Ctrl-C cancelar"
  rm -rf "${pMontaje01}"/*
  rm -rf "${pMontaje02}"/*
  rm -rf "${pMontaje03}"/*
fi;

mkdir -p "${pMontaje01}/${path}"
mkdir -p "${pMontaje02}/${path}"
mkdir -p "${pMontaje03}/${path}"

echo "Cambiando dueño y permisos"
chown -R oracle:oinstall "${pMontaje01}"/*
chown -R oracle:oinstall "${pMontaje02}"/*
chown -R oracle:oinstall "${pMontaje03}"/*

chmod -R 750 "${pMontaje01}"/*
chmod -R 750 "${pMontaje02}"/*
chmod -R 750 "${pMontaje03}"/*

echo "Verificando directorios creados"
echo "Direcotrio de datafiles"
cd "${dirDataFiles}"
cd ..
ls -l

echo "directorio de redo logs"
ls -l "${pMontaje01}"
ls -l "${pMontaje02}"
ls -l "${pMontaje03}"