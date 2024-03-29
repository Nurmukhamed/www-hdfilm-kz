---
layout: page
title: Руководство по настройке IPV6 на OpenWRT Breaking Barrier в сетях Интернет-Дома от Beeline  
date: 2019-01-19
comments: true
published: true
categories:
- openwrt
- ipv6
- tunnelbroker
- 6in4
- beeline
- l2tp
---

Краткая инструкция по настройке IPV6 в сетях Интернет-Дома от Билайна на роутерах OpenWRT.<!--more-->
 
## Предыстория

Потратил сегодня 2 часа разбираясь почему не работает IPV6 в OpenWRT.

**UPDATE**
* В данное время Beeline, TTC (Transtelecom) перешли на технологию [Carrier Grade Nat](https://en.wikipedia.org/wiki/Carrier-grade_NAT). Абоненту больше не выдается прямой IP-адрес. В связи с этим нет возможности настроить IPv6 через Hurricane Electric.
* Если все же есть необходимость в IPv6, необходимо приобрести дополнительную услугу "Прямой адрес" (услуга может называться иначе).
 
## Инструкция

### Шаг 1

Необходимо открыть страницу туннельного брокера [Hurricane Electric Free IPv6 Tunnel Broker](https://www.tunnelbroker.net/). 
Зарегистрироваться на сайте, создать первый туннель (если вы ранее не были зарегистрированы). Есть подсказка для openwrt.
Необходимо изменить данные под себя. Открываем putty, вставляем команды из подсказки. Перегружаемся.

{{< imgcap src="/images/20190119_ipv6_01.png" caption="20190119_ipv6_01.png" >}}


### Шаг 2

Через веб-интерфейс видим, что интерфейс был создан и добавлен в зону "WAN".

{{< imgcap src="/images/20190119_ipv6_02.png" caption="20190119_ipv6_02.png" >}}

### Шаг 3

Интерфейс существует, но не работает связь по IPv6. Виной тому, что интерфейс 6in4 использует в качестве адреса источника адрес интерфейса WAN.
А у нас в Beeline существует дополнительный интерфейс BEELINEKZ, через который мы выходим в интернет.

{{< imgcap src="/images/20190119_ipv6_03.png" caption="20190119_ipv6_03.png" >}}

### Шаг 4

Необходимо, чтобы сперва поднимался интерфейс BEELINEKZ, затем интерфейс HENET. В этом случае, туннель 6in4 будет использовать адрес BEELINEKZ как источник.
Решение простое - будем использовать hotplug.d, которые отслеживает состояние интерфейса. создайте простой скрипт, который будет отслеживать,
состояние интерфейса BEELINEKZ.
**Логика** - при поднятие интерфейса BEELINEKZ, останавливаем и стартуем интерефейс HENET. Скрипт ниже. После необходимо перегрузится.

{{< imgcap src="/images/20190119_ipv6_04.png" caption="20190119_ipv6_04.png" >}}

### Шаг 5

Откроем браузер и проверим состояние IPv6.

{{< imgcap src="/images/20190119_ipv6_05.png" caption="20190119_ipv6_05.png" >}}

### Шаг 6

Проверим также, через пинг сайта www.google.com

{{< imgcap src="/images/20190119_ipv6_06.png" caption="20190119_ipv6_06.png" >}}


