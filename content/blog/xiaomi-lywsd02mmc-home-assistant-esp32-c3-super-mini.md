---
title: "Подключаем Xiaomi Lywsd02mmc к Home Assistant"
date: 2025-09-08T12:44:55+05:00
summary: ""
categories:
- python
- bleak
- esp32
- esphome
- homeassistant
- xiaomi
- lywsd02mmc
---
Подключаем Xiaomi Lywsd02mmc к Home Assistant.
<!--more-->

# Предыстория

Давно купил себе датчик температуры, давления и часы с дисплеем на электронных чернилах. Только вот одна проблема - работают они только через Bluetooth и настроить их можно через Mi Home приложение.

Ну для первого раза с телефона на ОС Android я установил приложение, подключился к Mi Home, произвел первоначальную настройку.

А потом - все некогда было.

# Что нам нужно

Нам понадобится:

* Ноутбук с bluetooth адаптером;
* Телефон на ОС Andriod;
* Настроенный Home Assistant;
* Плата ESP32-C3-SuperMini.

# Настройка

Предполагаю, что все операции будут делаться с компьютера на базе ОС Linux, MacOS (ну у меня ноутбук).

## Python3

Подготовим необходимое окружение

~~~bash
cd
python3 -m venv esphome
source ./esphome/bin/activate
cd esphome
python3 -m pip install pip --upgrade
python3 -m pip install esphome
python3 -m pip install bleak

export ESPHOME_API_ENCRYPTION_KEY="$(openssl rand -base64 32)"

cat<<"EOF"| tee secrets.yaml
wifi_ssid: "MY_WIFI"
wifi_password: "MY_WIFI_PASSWORD"
api_encryption_key: "${ESPHOME_API_ENCRYPTION_KEY}"
EOF
~~~

## Ищем mac address нашего устройства

Для поиска устройства будем использовать библиотеку bleak и пример discover.py.

Пример для MacOS.

~~~bash
wget https://raw.githubusercontent.com/hbldh/bleak/refs/heads/develop/examples/discover.py
python3 discover.py --macos-use-bdaddr
~~~

Пример для Linux
~~~bash
wget https://raw.githubusercontent.com/hbldh/bleak/refs/heads/develop/examples/discover.py
python3 discover.py
~~~

Находим среди устройств наше устройство, сохраняем где-нибудь mac address (начинается на A4 или подобнее).

## Делаем активацию и получаем код активации

Нам нужен телефон, на телефоне нужно открыть [эту страницу](https://atc1441.github.io/TelinkFlasher.html).

Нажимаем кнопку "Connect", выбираем наше устройство, если не уверены, то можете перебрать устройства по списку один за другим по одному.

Нажимаем кнопку "Do activation", после данной операции должны заполнится поля "Device known id", "Mi Token", "Mi Bind Key".

Сделайте скриншот и запомните значение поля "Mi Bind Key".

## Устанавливаем время на термометре.

Нам нужен телефон, на телефоне нужно открыть [эту страницу](https://saso5.github.io/LYWSD02-clock-sync/).

Нажимаем кнопку "Update time". На термометре должно отобразится текущее время.

Если нам нужно, чтобы термометр показывал температуру в Фаренгейтах, то выбираем поле "F", нажимаем кнопку "Update units".

## Собираем прошивку ESPHOME.

Создайте файл esp32_xiaomi_lywsd02.yaml. Заполните файл

~~~yaml
esphome:
  name: esp32c3_xiaomi_lywsd02
  friendly_name: Test

  project:
    name: my.blethermo
    version: "1.0"

logger:
  level: debug

api:
  encryption:
    key: !secret api_encryption_key

esp32:
  board: esp32-c3-devkitm-1
  variant: ESP32C3
  framework:
    type: esp-idf

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password

dashboard_import:
  package_import_url: github://esphome/bluetooth-proxies/esp32-generic/esp32-generic-c3.yaml@25.5.1

packages:
  esphome.bluetooth-proxy: github://esphome/bluetooth-proxies/esp32-generic/esp32-generic-c3.yaml@25.5.1

sensor:
  - platform: xiaomi_lywsd02mmc
    mac_address: "ВСТАВИТЬ_MAC_ADDRESS_УСТРОЙСТВА"
    bindkey: "ВСТАВИТЬ_ЗНАЧЕНИЕ_ПОЛЯ_Mi_Bind_Key"
    temperature:
      name: "LYWSD02MMC Temperature"
    humidity:
      name: "LYWSD02MMC Humidity"
    battery_level:
      name: "LYWSD02MMC Battery Level"
~~~

Собираем прошивку.

~~~bash
esphome compile esp32_xiaomi_lywsd02.yaml
~~~

Подключаем плату ESP32-C3-SUPER-MINI к компьютеру, появится всплывающее окно, разрешаем доступ.
Заливаем прошивку на плату.

~~~bash
esphome upload esp32_xiaomi_lywsd02.yaml
~~~

Отключаем плату, затем включаем, на роутере смотрим какой адрес получила плата.

## Настройка HomeAssistant

Заходим на страницу HomeAssistant -> Настройки -> Устройства и службы -> Добавить интеграцию -> ESPHOME.

Набираем ip-адрес плату, затем API ENCRYPTION KEY, новое устройство будет добавлено.

После должна появится интеграция Xiaomi BLE, добавляем новое устройство, вводим Mi Band Key.

 
