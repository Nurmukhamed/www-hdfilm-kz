---
title: "Немного про Frigate NVR"
date: 2026-01-15T09:01:00+05:00
summary: ""
categories:
- nvr
- frigate
- camera
- surveillance
- python
- docker
- ubuntu
- debian
- systemd

---
Немного про Frigate NVR.
<!--more-->

[Frigate NVR](https://github.com/blakeblackshear/frigate) - это система, которая получает поток RTSP от различных источников - камеры, видеорегистраторы. Обрабатывает потоки,
определяет движение и все это в удобном UI.

В данный момент, у меня установлено 2 сервера frigate, которые работают в сельской местности, полностью автономно и не требуют внимания.

Решение включает в себя:

* [Frigate NVR](https://github.com/blakeblackshear/frigate)
* [HomeAssistant](https://www.home-assistant.io/)
* [Mosquitto](https://www.home-assistant.io/)
* [Telegram-Bot](https://github.com/OldTyT/frigate-telegram)
* [ESPHome](https://esphome.io/)
* [Coral EdgeTPU](https://www.coral.ai/products/)

Более подробно о решение [написано здесь](https://github.com/Nurmukhamed/homeserverfrigate). Но статья получилась сложной для восприятия, уровень Middle+.

В конце 2025 года я подумал, а можно ли запустить Frigate NVR на операционной системе без Docker и (или) виртуализации. 
Да у меня получилось запустить Frigate NVR, более подробнее [здесь](https://github.com/Nurmukhamed/barefrigate).
