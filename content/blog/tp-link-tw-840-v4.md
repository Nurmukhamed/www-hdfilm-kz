---
layout: page
title: Руководство по перепрошивке роутера Tp-Link TL-WR840N  
date: 2019-01-19
comments: true
published: true
categories:
- openwrt
- tp-link
- TL-WR840N
- firmware
- beeline
- l2tp
---

Инструкция с картинками, как прошить роутер <!--more-->

## WARNING - ПРЕДУПРЕЖДЕНИЕ

**Не для настройки Beeline L2TP на этой модели роутера**

**Для настройки Beeline L2TP будет написана отдельная статья**

Пожалуйста прочитайте инструкцию до конца статьи. 

Приступайте к работе только после прочтения статьи.

 
## Предыстория

Переехал в Алмату, на новой квартире был уже интернет от Казахтелекома, вроде все хорошо, но ужасный биллинг от Казахтелекома все портит. Сдал все оборудование,
отключил интернет от Казахтелекома. Подал заявку в Билайн, приехали ребята, прокинули кабель и подарили роутер. У меня уже есть роутер Mikrotik, который был настроен на Beeline 
и беспроблемно работал. Роутер новый от TP-Link, но почему-то прошивка от openwrt не загрузилась с веб-интерфейса. Начал искать в гугле, выяснил, что 
теперь все прошивки залочены. 
На сайте [4PDA.RU](https://4pda.ru/forum/index.php?showtopic=786959&st=180#entry60840562) нашел инструкцию. Но она совсем без картинок, надо исправить 
и создать свою инструкцию с картинками.

## Инструкция

### Шаг 1

Необходимо открыть страницу проекта [OpenWRT](https://openwrt.org/toh/hwdata/tp-link/tp-link_tl-wr840n_v4)

{{< imgcap src="/images/20190119_openwrt_01.png" caption="20190119_openwrt_01.png" >}}

### Шаг 2

Выбираем прошивку - восстановление через tftp. 

{{< imgcap src="/images/20190119_openwrt_02.png" caption="20190119_openwrt_02.png" >}}

### Шаг 3

Я использую директорию "Загрузки". Создаю под-директорию tplink, в эту директорию нужно переместить скачанный файл.

{{< imgcap src="/images/20190119_openwrt_03.png" caption="20190119_openwrt_03.png" >}}

### Шаг 4

Открываем страницу проекта [tftpd32](http://tftpd32.jounin.net/tftpd32_download.html). Это сервис tftp для Windows.

{{< imgcap src="/images/20190119_openwrt_04.png" caption="20190119_openwrt_04.png" >}}

### Шаг 5

Выбираем последний релиз программы. Скачиваем.

{{< imgcap src="/images/20190119_openwrt_05.png" caption="20190119_openwrt_05.png" >}}

### Шаг 6

Устанавливаем программу tftpd32

{{< imgcap src="/images/20190119_openwrt_06.png" caption="20190119_openwrt_06.png" >}}

### Шаг 7

Соглашаемся с лицензионным соглашением. 

{{< imgcap src="/images/20190119_openwrt_07.png" caption="20190119_openwrt_07.png" >}}

### Шаг 8

В директории tplink переименовываем файл в tp_recovery.bin.

{{< imgcap src="/images/20190119_openwrt_08.png" caption="20190119_openwrt_08.png" >}}

### Шаг 9

Изменяем настройки сети.

{{< imgcap src="/images/20190119_openwrt_09.png" caption="20190119_openwrt_09.png" >}}

### Шаг 10

Выбираем проводное соединение, заходим в "Свойства".

{{< imgcap src="/images/20190119_openwrt_10.png" caption="20190119_openwrt_10.png" >}}

### Шаг 11

Выбираем "Протокол Интернета версии 4 (TCP/IPv4)

{{< imgcap src="/images/20190119_openwrt_11.png" caption="20190119_openwrt_11.png" >}}

### Шаг 12

Назначаем IP-адрес на сетевую карту, адрес должен быть строго 192.168.0.66

{{< imgcap src="/images/20190119_openwrt_12.png" caption="20190119_openwrt_12.png" >}}

### Шаг 13

Запускаем программу tftpd32. При запуске программа использует значения по умолчанию.

{{< imgcap src="/images/20190119_openwrt_13.png" caption="20190119_openwrt_13.png" >}}

### Шаг 14

Изменяем значения по умолчанию. Выбираем директорию, где лежит файл tp_recovery.bin. Сетевой интерфейс выбираем с адресом 192.168.0.66

{{< imgcap src="/images/20190119_openwrt_14.png" caption="20190119_openwrt_14.png" >}}

### Шаг 15

Подключите компьютер и роутер сетевым патчкордом. Зажмите кнопку "Reset/WPS", подайте питание на роутер. Как только произойдет соединение с tftp-сервером,
отпустите кнопку "Reset/WPS". Подождите пару минут, роутер сам сделает необходимые действия.

**Поздравляю у вас есть готовый роутер с прошивкой OpenWRT.**

## Дальнейшие действия

В [этой статье](https://vk.com/@dchub_router-kak-podkluchit-l2tp-dlya-beeline-kz-internet-doma-na-primere) описано, как настроить роутер для сетей Beeline.
 
