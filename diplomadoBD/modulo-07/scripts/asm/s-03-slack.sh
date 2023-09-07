#!/bin/bash
echo "Iniciando raw devices"

echo "Asociando archivos img a un loop device"
path="/unam-diplomado-bd/loop-devices/asm"
for i  in 1 2 3 4 5 6 7
do
  #validando si ya existe el raw
  if [ -c "/dev/raw/raw${i}" ]; then
    echo "Ya existen raw device ${i}"
    continue;
  fi;
  
  disk="${path}/disk${i}.img" 
  loopDevice=$(losetup -f)
  rawDevice="/dev/raw/raw0${i}"

  #validando si loop device ya fue asociado a archivo img
  imgSetup=`losetup -a | grep "${disk}"`

  if [ "${imgSetup}" = "" ]; then
    echo "Asociando ${loopDevice} a ${disk}"
    losetup ${loopDevice}  ${disk}
  fi;

  echo "Generando  ${rawDevice}"
  raw ${rawDevice} ${loopDevice}

done

echo "Cambiando permisos a raw devices"
chown grid:asmdba /dev/raw/raw*
chmod 660 /dev/raw/raw*

echo "Mostrando raw devices"
ls -l /dev/raw/*