#!/bin/sh

# First time
passwd <<\__EOF__
a
a
__EOF__

if [ ! -d "/home/pig" ]; then
	useradd -m -G wheel pig
fi

passwd pig <<\__EOF__
a
a
__EOF__

sed -i.bak '/%wheel ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers
echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Packages
pacman -Syu --noconfirm
pacman -S \
    python python-pip \
    wget vim base-devel \
    --noconfirm

cat <<EOF >> /etc/pacman.conf
[archlinuxfr]
SigLevel = Never
Server = http://repo.archlinux.fr/arm
EOF

# yaourt
cd /tmp
rm -rf package-query*
sudo -u pig curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
sudo -u pig tar zxvf package-query.tar.gz
cd package-query
yes | sudo -u pig makepkg -si
pacman -S yaourt --noconfirm
