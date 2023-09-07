#!/bin/bash
echo "COnfigurando ambiente ASM"

echo "Creando grupos para ASM"
groupadd asmadmin
groupadd asmdba
groupadd asmoper

echo "Actualizando grupos del usuario oracle"
usermod -aG asmdba oracle

echo "Creando usaurio grid"
useradd -g oinstall -G asmadmin,asmoper,asmdba,dba grid

echo "Actualizando password de grid"
passwd grid

echo "Crear directorios"
mkdir -p /u01/app/grid
chown grid:oinstall /u01/app/
chown grid:oinstall /u01/app/grid

echo "Creando loop devices"
mkdir /unam-diplomado-bd/loop-devices/asm
chown grid:oinstall /unam-diplomado-bd/loop-devices/asm
cd /unam-diplomado-bd/loop-devices/asm

echo "Creando disk1.img de 3 Gb"
dd if=/dev/zero of=disk1.img  bs=1024M count=3

echo "Creando disk2.img de 3 Gb"
dd if=/dev/zero of=disk2.img  bs=1024M count=3

echo "Creando disk3.img de 3 Gb"
dd if=/dev/zero of=disk3.img  bs=1024M count=3

echo "Creando disk4.img de 3 Gb"
dd if=/dev/zero of=disk4.img  bs=1024M count=3

echo "Creando disk5.img de 3 Gb"
dd if=/dev/zero of=disk5.img  bs=1024M count=3

echo "Creando disk6.img de 3 Gb"
dd if=/dev/zero of=disk6.img  bs=1024M count=3

echo "Creando disk7.img de 3 Gb"
dd if=/dev/zero of=disk7.img  bs=1024M count=3

echo "Cambiando permisos de los img"
chown grid:asmdba *.img
chmod 660 *.img

# echo "Asociando archivos img a loop devices"
# for i in 1 2 3 4 5 6 7
# do
#   loopDevice=$(losetup -f)
#   disk="disk${i}.img"
#   rawDevice="/dev/raw/raw0${i}"

#   echo "Asociando ${loopDevice} a ${disk}"
#   losetup ${loopDevice} ${disk}

#   echo "Asociando ${loopDevice} a ${rawDevice}"
#   raw ${rawDevice} ${loopDevice}
# done

# losetup /dev/loop11 disk1.img
# losetup /dev/loop12 disk2.img
# losetup /dev/loop13 disk3.img
# losetup /dev/loop14 disk4.img
# losetup /dev/loop15 disk5.img
# losetup /dev/loop16 disk6.img
# losetup /dev/loop17 disk7.img

# echo "Verificando loop devices"
# losetup -a

# echo "Asociar loop devices como raw"
# raw /dev/raw/raw01 /dev/loop11 
# raw /dev/raw/raw02 /dev/loop12
# raw /dev/raw/raw03 /dev/loop13
# raw /dev/raw/raw04 /dev/loop14
# raw /dev/raw/raw05 /dev/loop15
# raw /dev/raw/raw06 /dev/loop16
# raw /dev/raw/raw07 /dev/loop17

# echo "Cambiando permisos a raw devices"
# chown grid:asmdba /dev/raw/raw*
# chmod 660 /dev/raw/raw*

# echo "Mostrando raw devices"
# ls -l /dev/raw/

#Asociando loop devices a raw devices
./s-03-raw-dev-start-root.sh

echo "Creando derectoio para instalar grid"
mkdir -p /u01/app/grid/product/19.3.0/grid
cd /u01/app
echo "Cambiando permisos para grid"
chown -R grid:oinstall grid

#ejecutar despues como root
mv /home/johanzr/Downloads/LINUX.X64_193000_grid_home.zip /u01/app/grid/product/19.3.0/grid
cd /u01/app/grid/product/19.3.0/grid
chown grid:oinstall LINUX.X64_193000_grid_home.zip
su -l grid
cd /u01/app/grid/product/19.3.0/grid
#unzip del grid_home.zip

#ejecutar xhost+
./gridSetup.sh
#terminal del grid
export CV_ASSUME_DISTID=OEL8