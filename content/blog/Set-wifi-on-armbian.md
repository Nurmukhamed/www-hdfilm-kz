---
layout: page
title: Настройка беспроводной сети в armbian для Orange Pi Zero Plus
date: 2020-01-17
comments: true
published: true
categories:
- linux
- armbian
- OrangePiZeroPlus
- wifi
- NetworkManager
- wpa_supplicant
- systemd
- systemd-networkd
- systemd-resolved
---

Как настроить беспроводную сеть на Orange Pi Zero Plus <!--more-->

## Предыстория
Это решение проблемы - если настраивать сеть стандартным способом через NetworkManager, то после перезагрузки wifi-сеть не работает.

## Решение

Отключаем NetworkManager, wpa_supplicant

```
sudo systemctl disable NetworkManager hostapd wpa_supplicant
```

Создадим новый параметризованный сервис wpa_supplicant@.service
```
cat <<"EOF" | sudo tee /etc/systemd/system/wpa_supplicant@.service
[Unit]
Description=WPA supplicant for %i

[Service]
ExecStart=/sbin/wpa_supplicant -i%i -c/etc/wpa_supplicant/wpa_supplicant.conf

[Install]
WantedBy=multi-user.target
EOF
```
Включаем сервисы

```
sudo systemctl enable systemd-networkd.service systemd-resolved.service wpa_supplicant@wlan0.service
```

Создаем профиль проводной сети

```
cat << "EOF" | sudo tee /etc/systemd/network/wired.network
[Match]
Name=eth0

[Network]
DHCP=yes

[DHCP]
RouteMetric=10
EOF
```

Создаем профиль беспроводной сети

```
cat << "EOF" | sudo tee /etc/systemd/network/wireless.network
[Match]
Name=wlan0

[Network]
DHCP=yes

[DHCP]
RouteMetric=10
EOF
```

Определяем SSID, к которым нужно подключатся

```
wpa_passphrase SSIDNAME SSIDPASS > /etc/wpa_supplicant/wpa_supplicant.conf
```

Перезагружаемся

```
sudo systemctl reboot
```

## Итог

Получилось настроить сеть, которая всегда работает и очень быстро подключается к сети.
