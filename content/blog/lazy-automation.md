---
layout: page
title: "Ленивая автоматизация"
date: 2022-06-27
comments: true
categories: 
- ubuntu
- bash
- automation
- homeassistant
- DRY
---

** Небольшая памятка про ленивую автоматизацию**
<!-- more -->

**Предисловие**:

С прошлого года в квартире установлен шлюз умного дома, датчик открывания двери переделан как счетчик холодной воды. 
Устанвлен HomeAssistant, [счетчик воды](https://imgur.com/Sobuv1k) (геркон) дает 1 импульс на 1 литр воды (1000 импульсов 1 куб воды).


**Задача**:

С течением времени данные между счетчиком холодной воды и в HomeAssistant начали расходится. На сегодня разница составила в 3 с лишним куба.

Но я не нашел способа повысить значение счетчика простым способом. Чтобы повысить значение, нужно нажимать кнопку increment. Но нажимать 3000 раз мышь - это же такой труд.

**Ссылки**

[Ссылка1](https://askubuntu.com/questions/179581/how-can-i-make-my-mouse-auto-click-every-5-seconds)
[Ссылка2](https://stackoverflow.com/questions/8480073/how-would-i-get-the-current-mouse-coordinates-in-bash)


**Решение**

Сперва необходимо определить куда нужно нажимать левую кнопку мышки.

```
watch -t -n 0.0001 xdotool getmouselocation
```

Затем запускаем бесконечный цикл, который будет нажимать левую кнопку раз в секунду.

```

while [ 1 ]; do
	xdotool mousemove XXXX YYY click 1 &
	sleep 1
done
```

пока процесс идет, можем посмотреть [Youtube](https://youtu.be/RLtjotH4Ozk).
