---
title: "Проблема с nfs-шарой в Le Potato, transmission"
date: 2025-12-08T12:44:55+05:00
summary: ""
categories:
- le potato
- pi
- python
- transmission
- torrent
- nfs
- nfs-client
- systemd
- bash
---

Случай из практики - nfs-шара не подключалась после перезагрузки.

<!--more-->

# Intro - Введение

Использую [le potato](https://libre.computer/products/aml-s905x-cc/) c [OS Debian](https://www.debian.org/index.ru.html) как [торрент-клиент Transmission](https://transmissionbt.com/).

Transmission работает без проблем, но место маловато на самой плате, решил подключить nfs-шару c другого сервера.

Создал systemd mount файл, включил nfs-шару, включил transmission - все работает.

~~~bash
cat<<EOT | sudo tee /etc/systemd/system/opt-transmission/downloads.mount
[Unit]
Description=NFS Share Mount
After=network-online.target

[Mount]
What=192.168.1.2:/public/torrent
Where=/opt/transmission/downloads
Type=nfs
Options=defaults,noatime,hard,intr,tcp,vers=4

[Install]
WantedBy=multi-user.target
EOT
~~~

Создал override-файл для transmission-daemon.service

~~~bash
cat<<EOT | sudo tee /etc/systemd/system/transmission-daemon.service.d/99-after-nfs.conf
[Unit]
Requires=opt-transmission-downloads.mount
After=opt-transmission-downloads.mount
EOT
~~~

Делаю запуск - все работает

~~~bash
sudo systemctl daemon-reload
sudo systemctl enable --now opt-transmission-downloads.mount
sudo systemctl start transmission-daemon.service
~~~


Делаю перезагрузку, nfs-шара не подключена, transmission не запущен.

Ну начал разбираться.

# Problem - Описание проблемы

Основная проблема - network-online.target - быстро стартует и сообщает systemd, что все хорошо, systemd начинает загружать units, mounts,
в которых указана зависимость от network-online.target.

Это происходит очень быстро, nfs-client не успевает правильно загрузится и не может подключить nfs-шару.

# Solution - Решение проблемы

Ну я пришел к простому решению - создать новый unit, который будет:

* ждать, пока сеть будет готова;
* подключить nfs-шару;
* запустить transmission.

Нам понадобится скрипт

~~~bash
cat<<EOT | sudo tee /usr/local/bin/nfs-transmission-starter.sh
#!/bin/bash

# Borrowed from here
# https://askubuntu.com/questions/929659/bash-wait-for-a-ping-success

printf "%s" "waiting for NFS Server ..."
while ! ping -c 1 -n -w 1 192.168.1.2 &> /dev/null
do
    printf "%c" "."
done
printf "\n%s\n"  "NFS Server is back online"

systemctl start opt-transmission-downloads.mount
systemctl start transmission-daemon.service
EOT

sudo chmod a+x /usr/local/bin/nfs-transmission-starter.sh
~~~

Systemd unit

~~~bash
cat<<EOT | sudo tee /etc/systemd/system/nfs-tranmission-starter.service
[Unit]
Description=NFS Transmission Starter
After=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
ExecStart=/usr/local/bin/nfs-transmission-starter.sh

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl daemon-reload

sudo systemctl disable --now opt-transmission-downloads.mount
sudo systemctl disable --now transmission-daemon.service

sudo systemctl enable --now nfs-transmission-starter.service
~~~
