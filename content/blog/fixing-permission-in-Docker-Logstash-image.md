---
layout: post
title: Правильные права на сертификаты в Docker-образе Logstash
date: '2020-08-24 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- docker
- elk
- elasticsearch
- kibana
- logstash
- rsa
- permission
---

**Правильные права на сертификаты в Docker-образе Logstash** <!--more-->

Потерял несколько часов пытаясь запустить Docker-образ Logstash.

**На будущее** - Сертификаты, а может и папка с config, pipeline должны принадлежать пользователю logstash (1000), группа logstash (1000).

Более подробно об этом читайте [здесь](https://github.com/logstash-plugins/logstash-input-beats/issues/197).