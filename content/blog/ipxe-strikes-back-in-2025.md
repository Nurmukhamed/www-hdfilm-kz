---
title: "Настраиваем сетевую загрузку с помощью mikrotik, ipxe, bios, uefi"
date: 2025-10-21T12:44:55+05:00
summary: ""
categories:
- mikrotik
- netboot
- bios
- uefi
- pxe
- ipxe

---

Настраиваем сетевую загрузку с помощью mikrotik, ipxe для bios, uefi.
<!--more-->

# Intro

Купил себе два HP Proliant Microserver Gen8, один рабочий, другой не рабочий. Обновил bios, iLO. До последних версии. В принципе покупал
сервера только из-за наличия iLO4, с надеждой, что можно эти сервера настроить и отправить в сельскую местность, в случае неисправности через iLO4 можно решить вопросы.

Так же есть слот MicroSD. Куда можно разместить emmc и установить систему, но их у меня пока нет.

Но сервера старые, там нет возможности загрузить с UEFI (и это для 2012 года, вроде тогда уже везде было). 

Помучался несколько дней, для себя нашел верный вариант, загружаемся по сети, загружаем ipxe, затем уже в ipxe загружаемся с 0 диска. Ну еще для себя написал небольшое меню с возможностью установить Rocky Linux 8 версии. Другие версии и дистрибутивы в принципе тоже можно добавить. Просто нет такого желания.

# Что используем?

* mikrotik router - как dhcp-server и откуда указываем где tftp-сервер и какие файлы нужно загрузить;
* h96max tv box - используется как tftp-сервер и http сервер. Отсюда загружаются нужные нам файлы;
* ipxe - создаем два образа для сетевой загрузки - для BIOS и для UEFI;
* podman - в контейнере собираем ipxe.

# Podman

Где нибудь на сервере и (или) рабочей машине под платформой AMD64 будем запускать podman необходимой нам для сборки ipxe.

Для начала создадим [ipxe embedded script](https://ipxe.org/embed) файл.
~~~bash
mkdir -p ipxe
cd ipxe

cat<<EOF | tee ipxe myscript.ipxe
#!ipxe

dhcp
chain http://192.168.1.18/default.ipxe
EOF

~~~ 

~~~bash
podman run -it --rm -v $(pwd):/app debian:12 bash

apt update -y
apt install build-essential git liblzma-dev -y
git clone https://github.com/ipxe/ipxe.git

cd ipxe/src
make bin/undionly.kpxe EMBED=/app/myscript.ipxe
cp bin/undionly.kpxe /app
make bin-x86_64-efi/ipxe.efi EMBED=/app/myscript.ipxe
cp bin-x86_64-efi/ipxe.efi /app
exit
~~~ 

Полученные файлы undionly.kpxe, ipxe.efi нам нужно скопировать на h96max.

# Mikrotik

Скопирую свои настройки, нужно просто адаптировать под свои нужды

~~~bash
[admin@MikroTik] /ip dhcp-server> export 

/ip dhcp-server

add address-pool=dhcp disabled=no interface=bridge name=defconf

/ip dhcp-server option

add code=66 name=TFTP value="'192.168.1.18'"

add code=67 name=Bootfile value="'undionly.kpxe'"

add code=67 name=UEFI value="'ipxe.efi'"

/ip dhcp-server option sets

add name=TFTPD options=Bootfile,TFTP

add name=UEFI options=TFTP,UEFI

/ip dhcp-server network

add address=192.168.1.0/24 comment=defconf dhcp-option-set=TFTPD dns-server=192.168.1.3 gateway=192.168.1.1 next-server=192.168.1.18
~~~

По умолчанию сетевая загрузка проходит в BIOS Legacy режиме, если нам нужно загрузить систему через UEFI, то нужно в Mikrotik UI выбрать lease и изменить options sets - выставить UEFI.

После этого данный lease host будет загружать ipxe.efi.

# H96Max

Данную железку я купил по совету ["У Павла"](https://psenyukov.ru/%d1%83%d1%81%d1%82%d0%b0%d0%bd%d0%be%d0%b2%d0%ba%d0%b0-armbian-%d0%b8-home-assistant-%d0%bd%d0%b0-tv-box-h96-max-%d0%bd%d0%b0-%d0%bf%d1%80%d0%be%d1%86%d0%b5%d1%81%d1%81%d0%be%d1%80%d0%b5-rockchip-rk33/), в 2025 по сути стоящая замена для raspberry pi. Так как их наштамповали миллионы и продается не дорого.

Также хорошо, что есть emmc на 32 и 64 ГБ. 

Также я туда перенес pi.hole.

Нужно установить tftp и http сервера.

~~~bash
sudo apt update -y
sudo apt install -y tftp-hpa tftpd-hpa nginx

sudo mkdir -p /srv/tftp
sudo chown tftp:tftp -R /srv/tftp

cat<<EOF | sudo tee /etc/default/tftpd-hpa
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="/srv/tftp"
TFTP_ADDRESS=":69"
TFTP_OPTIONS="--secure --create"
EOF

cp /tmp/undionly.kpxe /srv/tftp
cp /tmp/ipxe.efi /srv/tftp

sudo systemctl enable --now tftpd-hpa.service
sudo systemctl enable --now nginx.service

cat<<EOF | sudo tee /var/www/html/default.ipxe
#!ipxe

# Define variables for server details
set serverip 192.168.1.18
set repo mirror.ps.kz
set ksfile ks.cfg          # Kickstart file name

menu
  item --gap -- -------------------------- Rocky Linux 8 Installation --------------------------
  item rocky8_install Install Rocky Linux 8 (HTTP)
  item rocky8_install_ks Install Rocky Linux 8 (HTTP + Kickstart)
  item --gap -- -------------------------- Rocky Linux 9 Installation --------------------------
  item rocky9_install Install Rocky Linux 9 (HTTP)
  item rocky9_install_ks Install Rocky Linux 9 (HTTP + Kickstart)
  item --gap -- -------------------------- Rocky Linux 10 Installation --------------------------
  item rocky10_install Install Rocky Linux 10 (HTTP)
  item rocky10_install_ks Install Rocky Linux 10 (HTTP + Kickstart)
  item --gap -- -------------------------- Debian 12 (bootworm) Installation --------------------------
  item debian12_install Install Debian 12 (HTTP)
  item debian12_install_preseed Install Debian 12 (HTTP + Preseed)
  item --gap -- -------------------------- Debian 13 (trixie) Installation --------------------------
  item debian13_install Install Debian 13 (HTTP)
  item debian13_install_preseed Install Debian 13 (HTTP + Preseed)
  item --gap -- -------------------------- Devuan 5 (daedalus) Installation --------------------------
  item devuan5_install Install Devuan 5 (HTTP)
  item devuan5_install_preseed Install Devuan 5 (HTTP + Preseed)
  item --gap -- -------------------------- Devuan 6 (excalibur) Installation --------------------------
  item devuan6_install Install Devuan 6 (HTTP)
  item devuan6_install_preseed Install Devuan 6 (HTTP + Preseed)
  item --gap -- ----------------------------------------------------------------------------------
  item boot_from_hdd0 Boot from HDD0
  item boot_from_hdd1 Boot from HDD1
  item boot_from_hdd2 Boot from HDD2
  item boot_from_hdd3 Boot from HDD3
  item boot_from_hdd4 Boot from HDD4
  item boot_from_hdd5 Boot from HDD5
  item --gap -- ----------------------------------------------------------------------------------
  item reboot Reboot
  item exit Exit iPXE

# Default boot option
choose --default boot_from_hdd0 --timeout 15000 target && goto ${target}

:rocky8_install
  set osroot RockyLinux/8
  set webpath /rocky/8.10/BaseOS/x86_64/os        # Path on your web server where Rocky Linux 8 ISO content is extracted
  kernel http://${serverip}/${osroot}/vmlinuz inst.repo=http://${repo}${webpath} ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky8_install_ks
  set osroot RockyLinux/8
  set webpath /rocky/8.10/BaseOS/x86_64/os        # Path on your web server where Rocky Linux 8 ISO content is extracted
  kernel http://${serverip}/${osroot}/vmlinuz inst.repo=http://${repo}${webpath} ip=dhcp inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky9_install
  set osroot RockyLinux/9
  set webpath /rocky/9.7/BaseOS/x86_64/os        # Path on your web server where Rocky Linux 8 ISO content is extracted
  kernel http://${serverip}/${osroot}/vmlinuz inst.repo=http://${repo}${webpath} ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky9_install_ks
  set osroot RockyLinux/9
  set webpath /rocky/9.7/BaseOS/x86_64/os        # Path on your web server where Rocky Linux 8 ISO content is extracted
  kernel http://${serverip}/${osroot}/vmlinuz inst.repo=http://${repo}${webpath} ip=dhcp inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky10_install
  set osroot RockyLinux/10
  set webpath /rocky/10.1/BaseOS/x86_64/os        # Path on your web server where Rocky Linux 8 ISO content is extracted
  kernel http://${serverip}/${osroot}/vmlinuz inst.repo=http://${repo}${webpath} ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky10_install_ks
  set osroot RockyLinux/10
  set webpath /rocky/10.1/BaseOS/x86_64/os        # Path on your web server where Rocky Linux 8 ISO content is extracted
  kernel http://${serverip}/${osroot}/vmlinuz inst.repo=http://${repo}${webpath} ip=dhcp inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:debian12_install
  set osroot Debian/bookworm/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:debian12_install_preseed
  set osroot Debian/bookworm/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us preseed/url=http://${serverip}/$
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:debian13_install
  set osroot Debian/trixie/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:debian13_install_preseed
  set osroot Debian/trixie/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us preseed/url=http://${serverip}/$
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan5_install
  set osroot Devuan/daedalus/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan5_install_preseed
  set osroot Devuan/daedalus/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us preseed/url=http://${serverip}/$
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan6_install
  set osroot Devuan/excalibur/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan6_install_preseed
  set osroot Devuan/excalibur/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux priority=critical interface=auto netcfg/dhcp_timeout=200 language=en country=KZ locale=en_US.UTF-8 keymap=us preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:boot_from_hdd0
  sanboot --no-describe --drive 0x80

:boot_from_hdd1
  sanboot --no-describe --drive 0x81

:boot_from_hdd2
  sanboot --no-describe --drive 0x82

:boot_from_hdd3
  sanboot --no-describe --drive 0x83

:boot_from_hdd4
  sanboot --no-describe --drive 0x84

:boot_from_hdd5
  sanboot --no-describe --drive 0x85

:reboot
  reboot

:exit
  exit
~~~

Ну вроде все настроено и теперь можем использовать сетевую загрузку для различных задач.

