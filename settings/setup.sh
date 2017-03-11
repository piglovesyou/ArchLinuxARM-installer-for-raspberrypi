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

# yaourt
su ~ pig
wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
tar zxvf package-query.tar.gz
(cd package-query && makepkg --noconfirm --syncdeps --install)
wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
tar zxvf yaourt.tar.gz
(cdyaourt && makepkg --noconfirm --syncdeps --install)
