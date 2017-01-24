---
layout: post
title: "Как настроить статический адрес в скрипте ipxe. Правильный путь"
date: 2015-07-24 17:28:59 +0000
comments: true
categories: 
- ipxe
---

Как настроить статический адрес в скрипте ipxe, чтобы все работало?

<!-- more -->

Моя невнимательность приводит к тому, что некоторые проекты остаются не завершенными.


Долго не мог побороть настройку статических адресов в скрипте ipxe. 

{% codeblock %}
#!ipxe

set net0/ip 192.168.1.200
set net0/netmask 255.255.255.0
set net0/gateway 192.168.1.1
set net0/dns 192.168.1.1

chain http://boot.nurm.local/boot/${net0/mac:hexhyp}

{% endcodeblock %}

не работает. при загрузке ошибка и все.

{% img /images/ipxe-noifopen.PNG %}

но сегодня нашел функцию [ifopen](http://ipxe.org/cmd/ifopen), как сказано в описание "открывает" интерфейс.

изменил скрипт на

{% codeblock %}
#!ipxe

ifopen net0

set net0/ip 192.168.1.200
set net0/netmask 255.255.255.0
set net0/gateway 192.168.1.1
set net0/dns 192.168.1.1

chain http://boot.nurm.local/boot/${net0/mac:hexhyp}

{% endcodeblock %}

собрал новый образ, запустил в виртуальной машине, загрузка заработала. 


{% img /images/ipxe-ifopen.PNG %}

Нужно быть внимательным.
