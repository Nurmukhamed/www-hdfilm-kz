---
layout: post
title: Запускаем несколько экземпляров Consul на одной машине.
date: '2020-09-22 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- hashicorp
- consul
- systemd
---

**Запускаем несколько экземпляров Consul на одной машине.** <!--more-->

Разобрался как запускать несколько экземпляров Consul.

Данные:

| Путь                                          | Описание                            |
|-----------------------------------------------|-------------------------------------|
| /etc/consul.d/agent | Каталог настроек consul agent  |
| /etc/consul.d/agent/config.json | Общие настройки consul agent |
| /etc/consul.d/agent/ports.json | Настойки портов consul agent  |
| /etc/consul.d/server | Каталог настроек consul server  |
| /etc/consul.d/server/config.json | Общие настройки consul server  |
| /etc/consul.d/server/ports.json | Настройки портов consul server  |
| /var/lib/consul/agent | Каталог данных consul agent  |
| /var/lib/consul/server | Каталог данных consul server  |
| /etc/systemd/system/consul@.service | Параметризированная служба consul  |


Какие файлы нам пригодяться:

* Настройки consul agent
  * ports.json
```
{    "ports": {
         "https": 8501,
         "http": -1,
         "dns": 8600,
         "serf_lan": 8301,
         "serf_wan": 8302
     }
}
```
* Настройки consul server
  * ports.json
```
{    "ports": {
         "https": 8502,
         "http": -1,
         "dns": 8601,
         "serf_lan": 8303,
         "serf_wan": 8304
     }
}
```
* Параметризированная служба consul
  * consul@.service
```
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/%I/config.json


[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-dir=/etc/consul.d/%I
ExecReload=/bin/kill -SIGHUP $MAINPID
ExecStop=/usr/local/bin/consul leave
KillMode=process
Restart=on-failure
LimitNOFILE=65536
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target

```

**ВАЖНО** - Consul в режиме сервера слушает порт tcp/8300.

Создадим необходимые каталоги и запустим:

```
for service in agent server; do
    mkdir /etc/consul.d/${service}
    chown consul:consul /etc/consul.d/${service}
    mkdir /var/lib/consul/${service}
    chown consul:consul /var/lib/consul
    systemctl enable --now consul@${service}.service
done
```