---
layout: page
title: Перестановка железа на сервере и игровом компьютере дома в выходные
date: 2017-03-07
comments: true
published: true
categories:
  - домашний сервер
  - игровой компьютер
  - homeserver
  - games
  - world of tanks
---

Итоги перестановки сервера и игрового компьютера на выходных. <!--more-->

На прошлой неделе пришла посылка из Алматы от друга. Получил 5 модулей памяти DDR2-800 2Gb.
Проверил на компьютере работали только 4. Собрал еще один компьютер Core2Duo E8500 8Gb/750Gb/1.5Tb.

Раньше в качестве сервера был  Haswell Core i3/16GbRAM. Затем захотел играть в танки, докупил видеокарту GeForce 730, ssd samsung 750 256Gb и монитор Samsung. На минимальных настройках тянула танки в 115 фпс. Играла и не лагала.

Но позиция "домашний сервер" пустовало. У друзей выпросил старый комп, из Алматы подкинули память. вот и собран новый компьютер.

Сперва решил вернуть core i3 на место сервера. Все заработало. Без проблем. На новый компьютере перешли видеокарта и жесткий диск. Виндоус заработал без проблем, в танки тоже игралось. Но когда вечером сел поиграть часа 2-3, выяснилось, что есть какое-то подтормаживание небольшое. и как итог, все выстрелы в небо, не возможно нормально прицелится. 

Было принято решение:

- домашний сервер будет на core2duo;
- игровой компьютер на core i3.

Параметры домашнего сервера:

- Проц: Intel Core2Duo E8500;
- Материнская плата: GA-EP43-DS3L;
- Память: 4 * 2GB DDR2-800;
- Жесткие диски:
	- Samsung 2.5" 750Gb;
    - WD Green 3.5" 1.5Tb;
- Сетевые интерфейсы:
	- Realtek 8169;
    - Atheros Wifi;

Самое главное приемущество в материнской плате - 6 * USB2 портов есть, 4 слота PCIe x1. Достаточно, чтобы подключить дополнительные сетевые карты и gsm-брелки.
Также можно заменить процессор на xeon 771, получим 4 ядра, лучше будет виртуализация.

Планирую закупить [водянку на процессор](http://moon.kz/catalog/komplektuyushchie/sistemy_okhlazhdeniya/id_cooling/zhidkostnaya_sistema_okhlazhdeniya_id_cooling_frostflow_120l_led_2011_115x_775_amd_fan120_tdp150w/) в ближайший месяц два.

Параметры игрового компьютера:

- Проц: Intel Haswell Core i3;
- Материнская плата: MSI H81M-VG4;
- Память: 2 * 8Gb DDR3-1600;
- Жесткий диск:
	- Samsung SSD 750 256Gb;
- Видеокарта: Palit Geforce 730;

