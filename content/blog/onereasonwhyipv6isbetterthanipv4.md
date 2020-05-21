---
layout: page
title: "Почему IPv6 лучше чем IPv4"
date: 2015-07-14
comments: true
categories:
- ipv4
- ipv6
- winpe
- windows server
- network install
- ipxe
---

Маленькая статья о том почему IPv6 лучше чем IPv4
<!-- more -->

Сегодня занимался следующим:
Есть пару гипервизоров ESXi, нужно по сети устанавливать Windows Server 2012 R2 на виртуальные машины. 
Без вмешательства инженера, в автономном режиме.

Какие статьи использовал:

1. [Using VMware Tools drivers on Windows PE][1]
2. [Inject VMware Drivers into Windows Server 2012 ISO Image][2]
3. [How to create bootable Windows 8 ISO DVD using Oscdimg.exe][3]
4. [Установка Windows 7 по сети при помощи Microsoft Windows AIK][4]
5. [Установка Windows Server 2008 по сети с Linux PXE сервера. Кастомизация образа WinPE][5]
6. [Is it possible to use IPv6 to connect to a remote share using 'net use'?][6]
7. [Пакет автоматической установки Windows® (AIK) для Windows® 7][7]

Что необходимо сделать:

1. Установить [Windows AIK][7]
2. Создать образ WinPe, описано [здесь][4], [здесь][5] и [здесь][2]
3. Добавить драйвера VmWare в winpe.wim, описано [здесь][1], [здесь][2]
4. Изменить файл startnet.cmd, добавить свой сценарий, описано [здесь][4], [здесь][5]
5. Создать iso-образ, описано [здесь][3] 
6. Запустить ВМ
7. Загрузиться с iso-образа


Возникла проблема:

winpe загрузился, драйвера подгрузились, скрипт назначил адрес и не смог подключится к сетевому диску.
Если команды набрать в ручном режиме все проходило. 

Начал разбираться и выяснил, что во всех примерах предполагается использование DHCP-сервера  в сети. у меня нет
DHCP-cервера. Такие требование на работе к серверам. 

Решение:

В качестве решения нужно использовать IPv6. Если интерфейсе подняли IPV6, то на интерфейсе 
будет адрес link-local. Изменил скрипт загрузки на IPv6 и все заработало.

Пример starnet.cmd с IPv4

```
wpeinit

chcp 1251
netsh interface ip set address "Подключение по локальной сети" 192.168.1.20 255.255.255.0 192.168.1.1

cp866
net use z: \\192.168.1.253\Disk Password \user:Install

z:\WS2012\setup.exe 
```

Пример starnet.cmd с IPv6

```
wpeinit

net use z: \\fe80--42-acff-fe11-fb8.ipv6-literal.net\Disk Password \user:Install

z:\WS2012\setup.exe 
```

[1]: http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1011710 "Статья 1"
[2]: http://www.derekseaman.com/2012/10/inject-vsphere-drivers-into-windows.html "Статья 2"
[3]: http://www.windowsvalley.com/create-bootable-windows-8-iso-dvd/ "Статья 3"
[4]: http://habrahabr.ru/post/171017/ "Статья 4"
[5]: http://habrahabr.ru/company/serverclub/blog/213007/ "Статья 5"
[6]: http://serverfault.com/questions/566382/is-it-possible-to-use-ipv6-to-connect-to-a-remote-share-using-net-use "Статья 6"
[7]: https://www.microsoft.com/ru-ru/download/details.aspx?id=5753 "Статья 7"

