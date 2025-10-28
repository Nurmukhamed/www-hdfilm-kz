---
title: "Настройка часов точного времени DS3231 на Debian 12 для платы Le Potato AML-S905X-CC"
date: 2025-10-28T12:44:55+05:00
summary: ""
categories:
- raspberry pi
- pi
- le potato
- s905x
- debian
- rtc
- ds3231
- i2c

---
Настройка часов точного времени DS3231 на Debian 12 для платы Le Potato AML-S905X-C.
<!--more-->

# Предыстория

Для одного своего хобби-проекта купил себе 5 штук модулей DS3231-module-for-pi. Дома был еще LePotato, решил туда добавить.

Оказалось, что настройка под armbian и debian сильно отличается. Что стало поводом сделать конспект и сохранить на будущее.

# Commands

Необходимо зайти в систему

## Remove Fake HWClock.

~~~bash
sudo systemctl disable fake-hwclock.service
sudo apt remove -y fake-hwclock

sudo systemctl reboot
~~~

## Add ltdo i2c.
~~~bash
/usr/bin/ldto enable i2c-ao
/usr/bin/ldto enable i2c-ao-ds3231
/usr/bin/ldto merge

i2cdetect -y 1

hwclock --show
~~~

Теперь данные времени должны браться с DS3231. 

Если мы перезагрузимся, то все настройки слетят.

Сделаем отдельный systemd service, который будет при старте все настраивать.

~~~bash
cat<<EOF | sudo tee /etc/systemd/system/ds3231-setup.service
[Unit]
Description=Setup DS3231 realtime clock on system.
Documentation=https://www.hdfilm.kz
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ds3231-setup.sh
EOF

cat<<EOF | sudo tee /usr/local/bin/ds3231-setup.sh
#!/bin/bash
#
/usr/bin/ldto enable i2c-ao
/usr/bin/ldto enable i2c-ao-ds3231
/usr/bin/ldto merge

i2cdetect -y 1

hwclock --show
EOF

sudo chmod a+x /usr/local/bin/ds3231-setup.sh
sudo systemctl daemon-reload
sudo systemctl enable ds3231-setup.service
~~~


