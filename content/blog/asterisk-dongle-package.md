---
layout: post
title: Сборка пакета asterisk-chan_dongle
date: '2020-06-16 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- centos
- asterisk
- chan_dongle
- rpm
---

**Сборка пакета asterisk-chan_dongle** <!--more-->

# Почему?

У меня есть пару Huawei E173 модемов, которые обычно были подключены к orangepi, настроены на asterisk и работали.

Но теперь модемы переехали на сервера CentOS 7. Но вот мне не хочется засорять систему установкой лишних пакетов, поэтому я решил собрать пакет и установить его.

Готовые пакеты можно скачать [отсюда](http://repo.edenprime.kz).

# Сборка пакетов asterisk

Я использую mock для сборки пакетов. Также у меня настроено окружение rpmbuild.

Для начала нам нужно скачать файлы с [репозитория Fedora](https://src.fedoraproject.org/rpms/asterisk/tree/master). Это рабочая сборка для версии 17.5.0.
Сборка прошла успешно и теперь можно приступать к созданию пакета asterisk-dongle.

# Сборка пакетов asterisk-dongle

При сборке я столкнулся с проблемой - пакет asterisk-devel не включает в себя include-файлы. Мне пришлось вырезать эти файлы в отдельный архив. И этот архив включить в состав пакета asterisk-dongle. После этого проблем со сборкой не возникло. 

# Установка asterisk-dongle

Установка пакета не составляет трудностей, настройку я делал по [следующей статье](https://onxblog.com/2019/01/15/asterisk-on-raspberrypi-centos7-e173-modem/).

```
curl -o /tmp/edenprime.repo http://repo.edenprime.kz/edenprime.repo
sudo mv /tmp/edenprime.repo /etc/yum.repos.d/
sudo yum clean all

sudo yum install asterisk asterisk-voicemail asterisk-dongle asterisk-ael asterisk-pjsip

```




