# --@Autor: Johan Axel Zarazua Ramirez 
# --@Fecha creación: 23/septiembre/2022 
# --@Descripción: Creacion de loop devices
#!/bin/bash
echo "Creando Loop Devices"
echo "Creando carpeta para guardar archivos img"
mkdir -p /unam-diplomado-bd/loop-devices

cd /unam-diplomado-bd/loop-devices

if [[ -f "disk-01.img" || -f "disk-02.img" || -f "disk-03.img" ]]; then
  read -p "Archivos img encontrados [Enter para sobreescribir], Ctrl-c para cancelar"
  echo "Borrando archivos en caso de existir"
  rm -f disk-*.img
fi;

echo "Creando disk-01.img"
dd if=/dev/zero of=disk-01.img bs=100M count=10

echo "Creando disk-02.img"
dd if=/dev/zero of=disk-02.img bs=100M count=10

echo "Creando disk-03.img"
dd if=/dev/zero of=disk-03.img bs=100M count=10

echo "Verificando existencia de los archivos"
du -sh disk*.img

echo "Asociando archivo img a loop devices"
losetup -fP disk-01.img
losetup -fP disk-02.img
losetup -fP disk-03.img

echo "Mostrando creacion de loop devices"
losetup -a 

echo "Aplicando formato ext4 a los nuesvos dispositivos"
mkfs.ext4 disk-01.img
mkfs.ext4 disk-02.img
mkfs.ext4 disk-03.img


echo "Creando puntos de montaje"
mkdir -p /unam-diplomado-bd/disk-01
mkdir -p /unam-diplomado-bd/disk-02
mkdir -p /unam-diplomado-bd/disk-03

echo "Listo!"