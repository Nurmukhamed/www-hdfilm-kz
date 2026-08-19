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
- tftp
- dnsmasq
---

Настраиваем сетевую загрузку с помощью mikrotik, ipxe для bios, uefi.
<!--more-->

# update 
**2026-08-12**: 

Убрал раздел Podman, будем использовать готовые файлы, исправил uefi network boot.

Я решил проверить как работает UEFI network boot и у меня не получилось. Начал разбираться, выяснил, что лучше не использовать ipxe.efi, а нужно использовать snponly.efi. Более подробнее [здесь](https://github.com/warewulf/warewulf3/issues/84).

Добавил настройки для dnsmasq.

Имя http server изменено на boot.nurm.lan.

**2026-07-27**: Сделал форматирование текста для лучшего восприятия информации и уменьшил длину строк.

**2026-07-18**: Добавил ansible-playbook для обновления Linux distros.

**2026-01-21**: Добавил ansible-playbook.

**2026-06-03**: На хабре выложили отличную статью [iPXE без лишних слов, но с большим количеством пояснений](https://habr.com/ru/articles/1037416/), рекомендую ознакомится. Также добавлена опция 175 для ipxe.

# Intro

Купил себе два HP Proliant Microserver Gen8, один рабочий, другой не рабочий. Обновил bios, iLO. До последних версии. В принципе покупал
сервера только из-за наличия iLO4, с надеждой, что можно эти сервера настроить и отправить в сельскую местность, в случае неисправности через iLO4 можно решить вопросы.

Так же есть слот MicroSD. Куда можно разместить emmc и установить систему, но их у меня пока нет.

Но сервера старые, там нет возможности загрузить с UEFI (и это для 2012 года, вроде тогда уже везде было). 

Помучался несколько дней, для себя нашел верный вариант, загружаемся по сети, загружаем ipxe, затем уже в ipxe загружаемся с 0 диска. Ну еще для себя написал небольшое меню с возможностью установить Rocky Linux 8 версии. Другие версии и дистрибутивы в принципе тоже можно добавить. Просто нет такого желания.

# Обновление

* [Как настроить статический адрес в скрипте ipxe. Правильный путь](https://hdfilm.kz/blog/2015/07/24/ipxe-set-static-address-right-way/index.html)
* [Примеры kickstart, preseed.cfg файлов](https://hdfilm.kz/blog/2026/08/05/kickstarts-and-preseeds-files/index.html)
* [Настраиваем сетевую загрузку с помощью dnsmasq, ipxe, bios, uefi](https://hdfilm.kz/blog/2026/08/12/ipxe-dnsmasq-dhcp-tftp-setup/index.html)
* [Устанавливаем Windows 7 в 2023 году.](https://hdfilm.kz/blog/2023/03/20/installing-windows7-in-2023/index.html*)
* [Как заменить образ сетевой карты в виртуальной машине на образ ipxe](https://hdfilm.kz/blog/2015/07/24/vmwareaddipxemromtovmsnicbios/index.html)
* [Настраиваем сетевую загрузку talos](https://hdfilm.kz/blog/2026/08/18/ipxe-talos-setup/index.html)
# Что используем?

* mikrotik router - как dhcp-server и откуда указываем где tftp-сервер и какие файлы нужно загрузить;
* h96max tv box - используется как tftp-сервер и http сервер. Отсюда загружаются нужные нам файлы;
* ipxe - создаем два образа для сетевой загрузки - для BIOS и для UEFI;

# Mikrotik

Скопирую свои настройки, нужно просто адаптировать под свои нужды

~~~bash
[admin@MikroTik] /ip dhcp-server> export 

/ip dhcp-server

add address-pool=dhcp disabled=no interface=bridge name=defconf

/ip dhcp-server option

add code=66 name=TFTP value="'192.168.1.18'"

add code=67 name=Bootfile value="'undionly.kpxe'"

add code=67 name=UEFI value="'snponly64.efi'"

add code=175 name=iPXE value="'http://boot.nurm.lan/ipxe/boot.ipxe'"

/ip dhcp-server option sets

add name=TFTPD options=Bootfile,TFTP,iPXE

add name=UEFI options=TFTP,UEFI,iPXE

/ip dhcp-server network

add address=192.168.1.0/24 comment=defconf dhcp-option-set=TFTPD dns-server=192.168.1.3 gateway=192.168.1.1 next-server=192.168.1.18
~~~

По умолчанию сетевая загрузка проходит в BIOS Legacy режиме, если нам нужно загрузить систему через UEFI, то нужно в Mikrotik UI выбрать lease и изменить options sets - выставить UEFI.

После этого данный lease host будет загружать snponly64.efi.

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

sudo systemctl enable --now tftpd-hpa.service
sudo systemctl enable --now nginx.service

mkdir -p /var/www/html/ipxe

cat<<EOF | sudo tee /var/www/html/ipxe/boot.ipxe
#!ipxe

set serverip boot.nurm.lan
set repo mirror.ps.kz
set ksfile ks.cfg

set ${next-server} boot.nurm.lan:80


:next
chain --replace --autofree menu.ipxe
EOF

cat<<EOF | sudo tee /var/www/html/ipxe/menu.ipxe
#!ipxe

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
  # Path on your web server where Rocky Linux 8 ISO content is extracted
  set webpath /rocky/8.10/BaseOS/x86_64/os 
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky8_install_ks
  set osroot RockyLinux/8
  # Path on your web server where Rocky Linux 8 ISO content is extracted
  set webpath /rocky/8.10/BaseOS/x86_64/os
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp \
         inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky9_install
  set osroot RockyLinux/9
  # Path on your web server where Rocky Linux 9 ISO content is extracted
  set webpath /rocky/9.8/BaseOS/x86_64/os
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky9_install_ks
  set osroot RockyLinux/9
  # Path on your web server where Rocky Linux 9 ISO content is extracted
  set webpath /rocky/9.8/BaseOS/x86_64/os
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp \
         inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky10_install
  set osroot RockyLinux/10
  # Path on your web server where Rocky Linux 10 ISO content is extracted
  set webpath /rocky/10.2/BaseOS/x86_64/os
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:rocky10_install_ks
  set osroot RockyLinux/10
  # Path on your web server where Rocky Linux 10 ISO content is extracted
  set webpath /rocky/10.2/BaseOS/x86_64/os
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot

:debian12_install
  set osroot Debian/bookworm/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:debian12_install_preseed
  set osroot Debian/bookworm/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us \
         preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:debian13_install
  set osroot Debian/trixie/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:debian13_install_preseed
  set osroot Debian/trixie/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us \
         preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan5_install
  set osroot Devuan/daedalus/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan5_install_preseed
  set osroot Devuan/daedalus/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us \
         preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan6_install
  set osroot Devuan/excalibur/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us
  initrd http://${serverip}/${osroot}/initrd.gz
  boot

:devuan6_install_preseed
  set osroot Devuan/excalibur/debian-installer/amd64
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language=en \
         country=KZ \
         locale=en_US.UTF-8 \
         keymap=us \
         preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg
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

# IPXE 

Необходимые нам файлы - undionly.kpxe, snponly.efi можно скопировать с [репозитория ipxe](https://github.com/ipxe/ipxe/releases/latest/download/ipxeboot.tar.gz).

~~~bash

cat<<EOF | sudo tee /srv/tftp/autoexec.ipxe
#!ipxe

dhcp

chain --autofree http://boot.nurm.lan/ipxe/boot.ipxe
EOF


cd /tmp
wget https://github.com/ipxe/ipxe/releases/latest/download/ipxeboot.tar.gz
tar zxvf ipxeboot.tar.gz

sudo cp ipxeboot/x86_64/undionly.kpxe /srv/tftp/undionly.kpxe
sudo cp ipxeboot/x86_64/snponly.efi /srv/tftp/snponly64.efi
sudo cp ipxeboot/i386/snponly.efi /srv/tftp/snponly32.efi
sudo chown 0644 \ 
     /srv/tftp/undionly.kpxe \
     /srv/tftp/snponly64.efi \
     /srv/tftp/snponly32.efi

sudo chown tftp:tftp -R /srv/tftp

rm -rf /tmp/ipxeboot*
~~~


# Ansible

Нужно было повторить установку еще два раза, ну вот появился повод настроить Ansible-playbook.
Чтобы разом можно было сделать установку на 2 хоста и (или) более.

Что нам нужно создать следующие файлы.

## ansible.cfg

~~~bash
[defaults]
inventory = inventory
~~~

## inventory

~~~bash
[netboot]
192.168.1.18

[netboot:vars]
ansible_user=support
ansible_port=22
#ansible_python_interpreter=/usr/bin/python3
~~~

# main.yaml

~~~yaml
---
- name: Install ipxe network boot.
  hosts: all
  become: true

  vars:
    server_ip: "boot.nurm.lan"

    repo: "mirror.ps.kz"

    _country: "KZ"
    _language: "en"
    _locale: "en_US.UTF-8"
    _keymap: "us"

    oses:
      - distroName: "RockyLinux"
        distroShortName: "rocky"
        distroVersion: "8"
        osRoot: 'RockyLinux/8'
        ks: "ks.cfg"
        webpath: "/rocky/8/BaseOS/x86_64/os"
      - distroName: "RockyLinux"
        distroShortName: "rocky"
        distroVersion: "9"
        osRoot: 'RockyLinux/9'
        ks: "ks.cfg"
        webpath: "/rocky/9/BaseOS/x86_64/os"
      - distroName: "RockyLinux"
        distroShortName: "rocky"
        distroVersion: "10"
        osRoot: 'RockyLinux/10'
        ks: "ks.cfg"
        webpath: "/rocky/10/BaseOS/x86_64/os"
      - distroName: "Debian"
        distroShortName: "debian"
        distroVersion: "12"
        distroVersionName: "bookworm"
        osRoot: "Debian/bookworm/debian-installer/amd64"
        preseed: "preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg"
        netboot_url: "https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz"
      - distroName: "Debian"
        distroShortName: "debian"
        distroVersion: "13"
        distroVersionName: "trixie"
        osRoot: "Debian/trixie/debian-installer/amd64"
        preseed: "preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg"
        netboot_url: "https://deb.debian.org/debian/dists/trixie/main/installer-amd64/current/images/netboot/netboot.tar.gz"
      - distroName: "Devuan"
        distroShortName: "devuan"
        distroVersion: "5"
        distroVersionName: "daedalus"
        osRoot: "Devuan/daedalus/debian-installer/amd64"
        preseed: "preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg"
        netboot_url: "https://pkgmaster.devuan.org/devuan/dists/excalibur/main/installer-amd64/current/images/netboot/netboot.tar.gz"
      - distroName: "Devuan"
        distroShortName: "devuan"
        distroVersion: "6"
        distroVersionName: "excalibur"
        osRoot: "Devuan/excalibur/debian-installer/amd64"
        preseed: "preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg"
        netboot_url: "https://pkgmaster.devuan.org/devuan/dists/daedalus/main/installer-amd64/current/images/netboot/netboot.tar.gz"
    hdds:
      - 0
      - 1
      - 2
      - 3
      - 4
      - 5

  handlers:
   - name: Daemon-reload
     ansible.builtin.systemd:
       enabled: true

   - name: Service-tftpd-hpa-started
     ansible.builtin.systemd:
       name: tftpd-hpa
       state: started
       enabled: true

   - name: Service-tftpd-hpa-started
     ansible.builtin.systemd:
       name: tftpd-hpa
       state: restarted
       enabled: true

  tasks:
    - name: Ensure that packages are installed.
      ansible.builtin.apt:
        name: "{{ item }}"
        state: present
      with_items:
        - tftp-hpa
        - tftpd-hpa
        - nginx

    - name: Ensure that nginx is enabled and started.
      ansible.builtin.systemd:
        name: nginx
        state: started
        enabled: true

    - name: Ensure that /srv/tftp is exist.
      ansible.builtin.file:
        path: /srv/tftp
        state: directory
        owner: tftp
        group: tftp
        mode: '0755'

    - name: Create or update /etc/default/tftpd-hpa.
      ansible.builtin.copy:
        content: |
          TFTP_USERNAME="tftp"
          TFTP_DIRECTORY="/srv/tftp"
          TFTP_ADDRESS=":69"
          TFTP_OPTIONS="--secure --create"
        dest: /etc/default/tftpd-hpa
        owner: root
        group: root
        mode: '0644'
      notify:
        - Daemon-reload
        - Service-tftpd-hpa-started
        - Service-tftpd-hpa-started

    - name: Ensure that /var/www/html/ipxe is exist.
      ansible.builtin.file:
        path: /var/www/html/ipxe
        state: directory
        owner: root
        group: root
        mode: '0755'

    - name: Create or update autoexec.ipxe.
      ansible.builtin.template:
        src: autoexec.ipxe.j2
        dest: /srv/tftp/autoexec.ipxe
        owner: root
        group: root
        mode: '0644'

    - name: Create or update boot.ipxe.
      ansible.builtin.template:
        src: boot.ipxe.j2
        dest: /var/www/html/ipxe/boot.ipxe
        owner: root
        group: root
        mode: '0644'

    - name: Create or update menu.ipxe.
      ansible.builtin.template:
        src: menu.ipxe.j2
        dest: /var/www/html/ipxe/menu.ipxe
        owner: root
        group: root
        mode: '0644'

    - name: Download pxeboot, netboot files.
      ansible.builtin.include_tasks: download_files.yaml
      with_items: "{{ oses }}"
      loop_control:
        loop_var: os
~~~

# download_files.yaml

~~~yaml
---
- name: Ensure that folder is exist.
  ansible.builtin.file:
    path: "/var/www/html/{{ os['osRoot'] }}"
    state: directory
    owner: root
    group: root
    mode: '0755'

- name: Download RedHat files.
  when:
    - os['distroShortName'] == "rocky"
  ansible.builtin.get_url:
    url: "http://{{ repo }}/{{ os['webpath'] }}/images/pxeboot/{{ item }}"
    dest: "/var/www/html/{{ os['osRoot'] }}/{{ item }}"
    owner: root
    group: root
    mode: '0644'
  with_items:
    - vmlinuz
    - initrd.img

- name: Download Debian files.
  when:
    - os['distroShortName'] in ['debian', 'devuan']
  ansible.builtin.unarchive:
    src: "{{ os['netboot_url'] }}"
    dest: "/var/www/html/{{ os['distroName'] }}/{{ os['distroVersionName'] }}"
    remote_src: true
    owner: root
    group: root
~~~

# autoexec.ipxe.j2

~~~
#!ipxe

dhcp

chain --autofree http://{{ server_ip }}/ipxe/boot.ipxe
EOF
~~~

# boot.ipxe.j2

~~~bash
#!ipxe

# Define variables for server details
set serverip {{ server_ip }}
set repo {{ repo }}
set ksfile ks.cfg          # Kickstart file name

set ${next-server} {{ server_ip }}:80

:next
chain --replace --autofree menu.ipxe
~~~

# menu.ipxe.j2

~~~bash
#!ipxe

menu
{% for os in oses %}
  item --gap -- -------------------------- {{ os['distroName'] }} {{ os['distroVersion'] }} Installation --------------------------
  item {{ os['distroShortName'] }}{{ os['distroVersion'] }}_install Install {{ os['distroName'] }} {{ os['distroVersion'] }} (HTTP)
{%   if os['ks'] is defined %}
  item {{ os['distroShortName'] }}{{ os['distroVersion'] }}_install_ks Install {{ os['distroName'] }} {{ os['distroVersion'] }} (HTTP + Kickstart)
{%   endif %}
{%   if os['preseed'] is defined %}
  item {{ os['distroShortName'] }}{{ os['distroVersion'] }}_install_preseed Install {{ os['distroName'] }} {{ os['distroVersion'] }} (HTTP + Preseed)
{%   endif %}
{% endfor %}
  item --gap -- ----------------------------------------------------------------------------------
{% for hdd in hdds %}
  item boot_from_hdd{{ hdd }} Boot from HDD{{ hdd }}
{% endfor %}
  item --gap -- ----------------------------------------------------------------------------------
  item reboot Reboot
  item exit Exit iPXE

# Default boot option
choose --default boot_from_hdd0 --timeout 15000 target && goto ${target}

{% for os in oses %}
:{{ os['distroShortName'] }}{{ os['distroVersion'] }}_install
  set osroot {{ os['osRoot'] }}
{%   if os['webpath'] is defined %}
  set webpath {{ os['webpath'] }}
{%   endif %}
{%   if os['distroShortName'] == 'rocky' %}
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp
  initrd http://${serverip}/${osroot}/initrd.img
{%   elif os['distroShortName'] == 'debian' %}
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language={{ _language }} \
         country={{ _country }} \
         locale={{ _locale }} \
         keymap={{ _keymap }}
  initrd http://${serverip}/${osroot}/initrd.gz
{%   elif os['distroShortName'] == 'devuan' %}
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language={{ _language }} \
         country={{ _country }} \
         locale={{ _locale }} \
         keymap={{ _keymap }}
  initrd http://${serverip}/${osroot}/initrd.gz
{%   endif %}
  boot
{%   if os['ks'] is defined %}
:{{ os['distroShortName'] }}{{ os['distroVersion'] }}_install_ks
  set osroot {{ os['osRoot'] }}
{%     if os['webpath'] is defined %}
  set webpath {{ os['webpath'] }}
{%     endif %}
  kernel http://${serverip}/${osroot}/vmlinuz \
         inst.repo=http://${repo}${webpath} \
         ip=dhcp \
         inst.ks=http://${serverip}/${osroot}/${ksfile}
  initrd http://${serverip}/${osroot}/initrd.img
  boot
{%   endif %}

{%   if os['preseed'] is defined  %}
:{{ os['distroShortName'] }}{{ os['distroVersion'] }}_install_preseed
  set osroot {{ os['osRoot'] }}
{%     if os['webpath'] is defined %}
  set webpath {{ os['webpath'] }}
{%     endif %}
  kernel http://${serverip}/${osroot}/linux \
         priority=critical \
         interface=auto \
         netcfg/dhcp_timeout=200 \
         language={{ _language }} \
         country={{ _country }} \
         locale={{ _locale }} \
         keymap={{ _keymap }} \
         preseed/url=http://${serverip}/${osroot}/preseeds/preseed.cfg
  initrd http://${serverip}/${osroot}/initrd.gz
  boot
  boot
{%   endif %}
{% endfor %}

{% for hdd in hdds %}
:boot_from_hdd{{ hdd }}
  sanboot --no-describe --drive 0x8{{ hdd }}
{% endfor %}

:reboot
  reboot

:exit
  exit
~~~

Запускаем плейбук следующей командой

~~~bash
ansible-playbook main.yaml -K
~~~

# Ansible - Linux distro update.

Небольшой плейбук для обновления RockyLinux, Debian установочных файлов.

~~~yaml
---
- name: Update Linux Distro netboot files.
  hosts: localhost
  connection: local
  become: true
  gather: true

  vars:
    _mirror_repo: "mirror.ps.kz"
    _distros:
      - name: Debian
        versions:
          - name: bookworm
            major: '12'
            minor: '15'
            url: 'https://%s/debian/dists/%s/main/installer-amd64/current/images/netboot/netboot.tar.gz'
          - name: trixie
            major: '13'
            minor: '6'
            url: 'https://%s/debian/dists/%s/main/installer-amd64/current/images/netboot/netboot.tar.gz'
      - name: RockyLinux
        versions:
          - major: '10'
            minor: '2'
            # urls:
            #  - 'https://mirror.ps.kz/rocky/10.2/BaseOS/x86_64/os/images/pxeboot/initrd.img'
            #  - 'https://mirror.ps.kz/rocky/10.2/BaseOS/x86_64/os/images/pxeboot/vmlinuz'
          - major: '9'
            minor: '8'
            # urls:
            #  - https://mirror.ps.kz/rocky/9.8/BaseOS/x86_64/os/images/pxeboot/initrd.img
            #  - https://mirror.ps.kz/rocky/9.8/BaseOS/x86_64/os/images/pxeboot/vmlinuz
          - major: '8'
            minor: '10'
            # urls:
            #  - https://mirror.ps.kz/rocky/8.10/BaseOS/x86_64/os/images/pxeboot/initrd.img
            #  - https://mirror.ps.kz/rocky/8.10/BaseOS/x86_64/os/images/pxeboot/vmlinuz

  pre_tasks:
    - name: Run apt update
      when: ansible_os_family == "Debian"
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

  tasks:
    - name: Check if rsync is installed.
      ansible.builtin.apt:
        name: rsync
        state: present

    - name: Create temporary folders.
      ansible.builtin.file:
        path: "/tmp/{{ item.0.name }}/{{ item.1.major}}.{{ item.1.minor }}"
        owner: root
        group: root
        mode: '0755'
        state: directory
      loop: "{{ _distros | subelements('versions') }}"

    - name: Download Debian files.
      when: item.0.name == 'Debian'
      ansible.builtin.unarchive:
        src: "{{ item.1.url | format (_mirror_repo, item.1.name) }}"
        dest: "/tmp/{{ item.0.name }}/{{ item.1.major }}.{{ item.1.minor }}"
        owner: root
        group: root
        remote_src: true
      loop: "{{ _distros | subelements('versions') }}"
      
    - name: Download RockyLinux files 1/2.
      when: item.0.name == 'RockyLinux'
      ansible.builtin.get_url:
        url: "https://{{ _mirror_repo }}/rocky/{{ item.1.major }}.{{ item.1.minor }}/BaseOS/x86_64/os/images/pxeboot/initrd.img"
        dest: "/tmp/{{ item.0.name }}/{{ item.1.major }}.{{ item.1.minor }}"
        owner: root
        group: root
      loop: "{{ _distros | subelements('versions') }}"

    - name: Download RockyLinux files 2/2.
      when: item.0.name == 'RockyLinux'
      ansible.builtin.get_url:
        url: "https://{{ _mirror_repo }}/rocky/{{ item.1.major }}.{{ item.1.minor }}/BaseOS/x86_64/os/images/pxeboot/vmlinuz"
        dest: "/tmp/{{ item.0.name }}/{{ item.1.major }}.{{ item.1.minor }}"
        owner: root
        group: root
      loop: "{{ _distros | subelements('versions') }}"

    - name: Rsync files - Debian.
      when: item.0.name == 'Debian'
      ansible.builtin.command:
        cmd: >
          rsync -avz 
          /tmp/{{ item.0.name }}/{{ item.1.major }}.{{ item.1.minor }}/
          /var/www/html/{{ item.0.name }}/{{ item.1.name}}/
      changed_when: false
      loop: "{{ _distros | subelements('versions') }}"

    - name: Rsync files - RockyLinux.
      when: item.0.name == 'RockyLinux'
      ansible.builtin.command:
        cmd: >
          rsync -avz 
          /tmp/{{ item.0.name }}/{{ item.1.major }}.{{ item.1.minor }}/
          /var/www/html/{{ item.0.name }}/{{ item.1.major}}/
      changed_when: false
      loop: "{{ _distros | subelements('versions') }}"
~~~

