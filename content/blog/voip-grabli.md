---
layout: page
title: "VOIP Грабли - Памятка для себя"
date: 2015-07-17
comments: true
categories: 
- voip
- asterisk
- freeswitch
- linux
- DRY
---

** Небольшая памятка, что не наступать на грабли**
<!-- more -->

Иногда мне звонят, пишут, просят посмотрет на asterisk, freeswitch, который почему-то не работает.
Задаешь вопросы - получаешь ответы, и потом лезешь к ним на сервера, смотришь в чем дело.
и было уже два раза, когда оказалось, что проблема в том, что firewall не правильный или сип сервер слушает
только на localhost. и об этом узнаешь, когда перепробывываешь все варианты. ну и еще веришь специалистам, они же 
должны были это проверить в первую очередь.


**Localhost**

команда 

```
netstat -an | grep ":5060"
```

ясно покажет, на каких интерфейсах работает voip сервер.


**Firewall**

Проверить как настроена трансляция адресов, поддерживает протоколы SIP-Alg, какие порты открыты

** Отправляйте тестовые пакеты**

Отправка тестового пакета покажет, где что не работает.
