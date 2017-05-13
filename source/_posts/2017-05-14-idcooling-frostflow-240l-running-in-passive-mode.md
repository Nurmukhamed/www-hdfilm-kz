---
layout: post
title: ID-Cooling Frostflow 240l - Работаем в пассивном режиме 
date: '2017-04-25 12:30:30 +0600'
comments: true
published: true
categories:
- watercooling
- id-cooling
- frostflow
- passive
- centos
- homeserver
- thingspeak
---

Краткий рассказ о системе необслуживаемой водянки, установленной в моем домашнем сервере. <!--more-->

На домашнем сервере установлена ID-Cooling Frostflow 240L. В корпус кое-как влезла. Пришлось отказаться от одного кулера, работать на одном кулере.

После переезда в Алматы, ешил заменить родной шумный кулер на более тихий, в Пульсере нашел [кулер](http://pulser.kz/?card=127044), купил, принес домой. Когда начал устанавливать, до меня дошло, что сам кулер 14см размера и вот никогда не влезет в обычные 12см.

Что делать?

Вариант №1 - прикрулитил кулер поверх корпуса, работает но не то. и не красиво.

Вариант №2 - решил посмотреть а как сервер будет работать в пассивном ре#!/bin/bash


чтобы спать спокойнее прикрутил скрипт для отсылки сообщении на [сервис thingspeak](https://thingspeak.com/channels/272287). Каждый час будет отсылатся температура обоих ядер на сервис.

вот небольшой скрипт для отсылки значений на сервис

<pre><code>
CORETEMP1=$(sensors | head -n 4 | grep "Core"| head -n 1 |awk ' { print $3 } '| cut -d "°" -f 1 | cut -d "+" -f 2)
CORETEMP2=$(sensors | head -n 4 | grep "Core"| tail -n 1 |awk ' { print $3 } '| cut -d "°" -f 1 | cut -d "+" -f 2)
KEY=THINGSPEAKKEY

curl http://api.thingspeak.com/update?key=${KEY}&field1=${CORETEMP1}&field2=${CORETEMP2}жиме.

</code></pre>

Посмотрим в течение месяца как себя покажет система охлаждения.