#!/bin/bash

##
# Check SDCard device path.
#
[ -z "${1+x}" ] # True if string empty.
ret=${?}
if [ ${ret} -eq 0 ]; then
    echo "SDCard device path is not set."
    exit 1
fi
echo SDCard device path is $1.
SDCARD_PATH=$1
BOOT_PARTITION_PATH=${SDCARD_PATH}p1
ROOT_PARTITION_PATH=${SDCARD_PATH}p2

#
# Check NIC IP address.
#
[ -z "${2+x}" ]
ret=${?}
if [ ${ret} -eq 0 ]; then
    echo IP Address is not set for systemd-networkd.
    exit 1
fi
echo IP Address is $2

#
# Check NIC gateway address.
#
[ -z "${3+x}" ]
ret=${?}
if [ ${ret} -eq 0 ]; then
    echo NIC gateway Address is not set for systemd-networkd.
    exit 1
fi
echo Gateway address is $3

#
# Check NIC DNS address.
#
[ -z "${4+x}" ]
ret=${?}
if [ ${ret} -eq 0 ]; then
    echo NIC DNS Address is not set for systemd-networkd.
    exit 1
fi
echo DNS Address is $4

NIC_CONFIG_PATH=root/etc/systemd/network/eth0.network
NIC_IPADDR=$2
NIC_GATEWAY=$3
NIC_DNS=$4

#
# Check Raspberry Pi Model 1, 2 or 3.
#
[ -z "${5+x}" ]
ret=${?}
if [ ${ret} -ne 0 -a \( "$5" -eq "1" -o "$5" -eq "2" -o "$5" -o "3" \) ]; then
    MODEL_NUM="$5"
else
    MODEL_NUM=3
fi
echo MODEL_NUM is $MODEL_NUM

#
# Registering Public Key
#
[ -z "${6+x}" ]
ret=${?}
if [ ${ret} -eq 0 ]; then
    echo Provide public key to register to /root/.ssh/authorized_keys
    exit 1
else
    PUBLIC_KEY="$6"
fi
echo PUBLIC_KEY is $PUBLIC_KEY

#
# Check and download Arch Linux ARM image.
#
if [ ${MODEL_NUM} = 1 ]; then
    IMAGE_FILE_NAME=ArchLinuxARM-rpi-latest.tar.gz
else
    IMAGE_FILE_NAME=ArchLinuxARM-rpi-${MODEL_NUM}-latest.tar.gz
fi
IMAGE_URL=http://archlinuxarm.org/os/${IMAGE_FILE_NAME}
echo $IMAGE_URL
if [ -f "./${IMAGE_FILE_NAME}" ]; then
    echo "${IMAGE_FILE_NAME} found."
else
    echo "${IMAGE_FILE_NAME} not found."
    echo "Download latest image..."
    wget ${IMAGE_URL}
fi

#
# Create Arch Linux ARM on SDCard.
#

echo "Create partition on SDCARD."

fdisk ${SDCARD_PATH} <<\__EOF__
o
n
p
1

+100M
t
c
a
n
p
2


t
2
83
w
__EOF__

sleep 2

#
# Create Arch Linux ARM on SDCard.
#
mkdir boot root
echo "Create filesystem and bootloader on SDCARD."

mkfs.vfat ${BOOT_PARTITION_PATH}
sleep 2s
mount ${BOOT_PARTITION_PATH} boot
mkfs.ext4 ${ROOT_PARTITION_PATH}
sleep 2s
mount ${ROOT_PARTITION_PATH} root
bsdtar -xpf ./${IMAGE_FILE_NAME} -C root
sync

mv root/boot/* boot

mount ${BOOT_PARTITION_PATH} boot
mount ${ROOT_PARTITION_PATH} root

#
# Settings
#
echo "Copy initial setup script file."
cp -f ./settings/setup.sh root/setup.sh

echo "Setting static ip address for systemd-networkd."
echo NIC IP address is ${NIC_IPADDR}
echo NIC Gateway address is ${NIC_GATEWAY}
echo NIC DNS address is ${NIC_DNS}

echo "[Match]" > ${NIC_CONFIG_PATH}
echo "Name=eth0" >> ${NIC_CONFIG_PATH}
echo "[Network]" >> ${NIC_CONFIG_PATH}
echo "DHCP=no" >> ${NIC_CONFIG_PATH}
echo "DNS=${NIC_DNS}" >> ${NIC_CONFIG_PATH}
echo "[Address]" >> ${NIC_CONFIG_PATH}
echo "Address=${NIC_IPADDR}/24" >> ${NIC_CONFIG_PATH}
echo "[Route]" >> ${NIC_CONFIG_PATH}
echo "Gateway=${NIC_GATEWAY}" >> ${NIC_CONFIG_PATH}

#
# Register Public Key
#
mkdir root/root/.ssh
chmod 600 root/root/.ssh
touch root/root/.ssh/authorized_keys
chmod 700 root/root/.ssh/authorized_keys
cat $PUBLIC_KEY > root/root/.ssh/authorized_keys
echo PUBLIC_KEY is registered from $PUBLIC_KEY

#
# Finalize
#
umount boot root
rm -rf boot root
#rm ${IMAGE_FILE_NAME} <-- better not delete...?

echo "Done!"
echo "Please remove SDCard, and insert your Raspberry Pi. Enjoy!"
