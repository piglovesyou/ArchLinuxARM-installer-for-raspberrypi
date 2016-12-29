#!/bin/sh

# Users
passwd <<\__EOF__
root
root
__EOF__

useradd -m -G wheel pig
passwd pig <<\__EOF__
pig
pig
__EOF__


# Keyboard
loadkeys jp106
echo 'KEYMAP=jp106' >> /etc/vconsole.conf


# Localtime
ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime


# Packages
pacman -Syu --noconfirm
pacman -S bluez bluez-utils python python-pip --noconfirm
pacman -S wget git vim dialog --noconfirm

cat <<EOF >> /etc/pacman.conf
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/$arch
EOF

pacman -S yaourt --noconfirm


# Services
systemctl start bluetooth.service
systemctl enable bluetooth.service
