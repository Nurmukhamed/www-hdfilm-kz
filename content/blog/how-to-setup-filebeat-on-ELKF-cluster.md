---
layout: post
title: Правильно устанавливаем filebeat на серверах.
date: '2020-09-08 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- elasticsearch
- kibana
- logstash
- filebeat
- pipeline
- setup
---

# **Правильно устанавливаем filebeat на серверах.** <!--more-->

**Все нижесказанное верно для версии 7.9.0**

Собрал все грабли по установке filebeat в одном месте:

## *Шаг №1* Включаем security на серверах Elasticsearch

[Инструкция](https://www.elastic.co/guide/en/elasticsearch/reference/current/configuring-security.html)

## *Шаг №2* Создаем роль filebeat_writers

[Инструкция](https://www.elastic.co/guide/en/beats/filebeat/master/feature-roles.html)

## *Шаг №3* Создаем пользователя filebeat_writer

[Инструкция](https://www.elastic.co/guide/en/beats/filebeat/master/feature-roles.html)

## *Шаг №4* Создаем index, ilm на Elasticsearch;

```
sudo filebeat setup -e \
    -E output.logstash.enabled=false   \
    -E output.elasticsearch.hosts=['http://127.0.0.1:9200'] \
    -E output.elasticsearch.username=elastic \
    -E output.elasticsearch.password=myfavoritepassword \
    -E setup.ilm.enabled: auto \
    -E setup.ilm.rollover_alias: "filebeat" \
    -E setup.ilm.pattern: "{now/d}-000001" \
    -E setup.kibana.host='http://127.0.0.1:5601'
```

## *Шаг №5* Создаем pipelines на Elasticsearch;

```
sudo filebeat setup -e \
    -E output.logstash.enabled=false \
    -E output.elasticsearch.hosts=['http://127.0.0.1:9200'] \
    -E output.elasticsearch.username=elastic \
    -E output.elasticsearch.password=myfavoritepassword \
    --pipelines \
    --modules auditd,nginx,system
```

## *Шаг №4* Создаем конфигурацию filebeat;

Здесь по инструкции настраиваем filebeat, настраиваем модули. Запускаем и собираем логи.

**Итог:**

* Получаем правильно настроенный Elasticsearch;
* Настроены dashboards, ilm, indices, pipelines;
* Можно теперь заскриптовать настройку ELKF;
