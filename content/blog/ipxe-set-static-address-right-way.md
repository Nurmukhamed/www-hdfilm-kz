---
layout: page
title: "Как настроить статический адрес в скрипте ipxe. Правильный путь"
date: 2015-07-24
comments: true
categories: 
- ipxe
---

Как настроить статический адрес в скрипте ipxe, чтобы все работало?

<!-- more -->

Моя невнимательность приводит к тому, что некоторые проекты остаются не завершенными.


Долго не мог побороть настройку статических адресов в скрипте ipxe. 

```
#!ipxe

set net0/ip 192.168.1.200
set net0/netmask 255.255.255.0
set net0/gateway 192.168.1.1
set net0/dns 192.168.1.1

chain http://boot.nurm.local/boot/${net0/mac:hexhyp}

```

не работает. при загрузке ошибка и все.

{% img /images/ipxe-noifopen.PNG %}

но сегодня нашел функцию [ifopen](http://ipxe.org/cmd/ifopen), как сказано в описание "открывает" интерфейс.

изменил скрипт на

```
#!ipxe

ifopen net0

set net0/ip 192.168.1.200
set net0/netmask 255.255.255.0
set net0/gateway 192.168.1.1
set net0/dns 192.168.1.1

chain http://boot.nurm.local/boot/${net0/mac:hexhyp}

```

собрал новый образ, запустил в виртуальной машине, загрузка заработала. 


{{< imgcap src="/images/ipxe-ifopen.PNG" caption="ipxe-ifopen.PNG" >}}

Нужно быть внимательным.
