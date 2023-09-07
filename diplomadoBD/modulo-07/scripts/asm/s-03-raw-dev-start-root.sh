#!/bin/bash
echo "Iniciando raw devices"

echo "Asociando archivos img a loop devices"
path="/unam-diplomado-bd/loop-devices/asm"
for i in 1 2 3 4 5 6 7
do
  #validandno si existe raw device
  if [ -c "/dev/raw/raw${i}" ]; then
    echo "Ya existe raw devices ${i} configurados"
    continue;
  fi;
  
  #validando si loop device ya fue asociado a img
  loopDevice=$(losetup -f)
  disk="${path}/disk${i}.img"
  rawDevice="/dev/raw/raw0${i}"

  #validacion de loop device asociado con un img
  imgSetup=`losetup -a | grep "${disk}"`
  if [ "${imgSetup}" = "" ]; then
    echo "Asociando ${loopDevice} a ${disk}"
    losetup ${loopDevice} ${disk}

  fi;  

  echo "Generando raw device ${rawDevice}"
  raw ${rawDevice} ${loopDevice}
done

echo "Cambiando permisos a raw devices"
chown grid:asmdba /dev/raw/raw*
chmod 770 /dev/raw/raw*

echo "Mostrando raw devices"
ls -l /dev/raw/