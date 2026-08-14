---
title: "Настраиваем сетевую загрузку с помощью dnsmasq, ipxe, bios, uefi"
date: 2026-08-12T12:44:55+05:00
summary: ""
categories:
- netboot
- ipxe
- bios
- uefi
- RockyLinux
- Debian
- dnsmasq
- dhcp
- tftp
---

Дополнение к статье [Настраиваем сетевую загрузку с помощью mikrotik, ipxe, bios, uefi][1].

<!--more-->

Решил добавить примеры dnsmasq для сетевой загрузки. 

# Intro

Недавно купил себе материнскую плату [D1581Q3A][2]. Обнаружил, что материнская плата поддерживает сетевую загрузку UEFI, но у меня не заработала сетевая загрузка.
Начал разбираться, ~~как никак написал же отдельный пост об этом~~, выяснил что нужно использовать файлы snponly.efi вместо ipxe.efi.
Внес изменения в оригинальный пост, исправил ошибки. Теперь можно сказать, что сетевая загрузка у меня работает в BIOS, UEFI 64 bit режимах.

Также купил себе старый ноутбук Lenovo Thinkpad T61, нужно на этом ноутбуке проверить загрузку по UEFI 32 bit. 

# Problem

mikrotik создает настройки dhcp-server, внутри мы опреляем набор dhcp options. Этот набор опции затем назначается всем dhcp leases.

Для примера, настроили сетевую загрузку по BIOS Legacy. Значит всем leases будет выдаваться только BIOS Legacy, а если железка не умеет в BIOS Legacy, 
то сетевая загрузка не будет работать. 

Либо заходим в настройки железки и там ставим BIOS Legacy, либо грузимся через флешку. Что не есть хорошо.

Либо заходим в настройки dhcp-сервера в mikrotik, находим нужный нам lease, и внутри данного lease меняем набор опции на поддержку UEFI опции.

Dnsmasq умеет с таким справляться. Dnsmasq получает запрос от устройства, и в зависимости от полученной опции может вернуть обратно устройству различные настройки.


# Dnsmasq

В нашей настройке dnsmasq выполняет только функции dhcp-сервера, tftp-сервера. DNS-сервером у нас занимаются другие.
Установка выполняется на TV-приставке H96Max Armbian, X96Max Debian. 

~~~bash

sudo apt update

sudo apt install -y dnsmasq

sudo mkdir -p /etc/dnsmasq.d
sudo mkdir -p /var/lib/tftpboot

cat<<EOF | sudo tee /etc/dnsmasq.d/10-main.conf
interface=eth0
port=0

dhcp-range=192.168.1.128,192.168.1.254,255.255.255.0,1h
dhcp-option=option:router,192.168.1.1
dhcp-option=option:dns-server,192.168.1.4
dhcp-authoritative
EOF

cat<<EOF | sudo tee /etc/dnsmasq.d/20-tftp.conf
enable-tftp
tftp-root=/var/lib/tftpboot
dhcp-no-override

# Enable only when need some debug information.
#log-dhcp

dhcp-userclass=set:ipxe,iPXE

dhcp-match=set:bios,option:client-arch,0
dhcp-match=set:efi32,option:client-arch,6
dhcp-match=set:efi64,option:client-arch,7
dhcp-match=set:efibc,option:client-arch,9

dhcp-boot=tag:efibc,snponly64.efi
dhcp-boot=tag:efi64,snponly64.efi
dhcp-boot=tag:efi32,snponly32.efi
dhcp-boot=tag:bios,undionly.kpxe

dhcp-boot=tag:ipxe,http://boot.nurm.lan/ipxe/boot.ipxe
EOF

cat<<EOF | sudo tee /var/lib/tftpboot/autoexec.ipxe
#!ipxe

dhcp

chain --autofree http://boot.nurm.lan/ipxe/boot.ipxe
EOF

cd /tmp
wget https://github.com/ipxe/ipxe/releases/latest/download/ipxeboot.tar.gz
tar zxvf ipxeboot.tar.gz

sudo cp ipxeboot/x86_64/undionly.kpxe /var/lib/tftpboot/undionly.kpxe
sudo cp ipxeboot/x86_64/snponly.efi /var/lib/tftpboot/snponly64.efi
sudo cp ipxeboot/i386/snponly.efi /var/lib/tftpboot/snponly32.efi
sudo chown 0644 \ 
     /var/lib/tftpboot/undionly.kpxe \
     /var/lib/tftpboot/snponly64.efi \
     /var/lib/tftpboot/snponly32.efi

rm -rf /tmp/ipxeboot*

sudo systemctl enable --now dnsmasq

sudo journalctl -u dnsmasq 
~~~

[1]: https://hdfilm.kz/blog/2025/10/21/ipxe-strikes-back-in-2025/
[2]: https://aliexpress.ru/item/1005010496675349.html?spm=a2g2w.orderdetail.0.0.4f2f4aa6c0qmT1&sku_id=12000052593201023

