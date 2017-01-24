---
layout: post
title: "Очень простой битторрент-трекер"
date: 2016-09-21 16:30:30 +0600
comments: true
categories: 
- bittorrent
- opentracker
- kitap.hdfilm.kz
---

На [своем сайте](kitap.hdfilm.kz) я раздаю сканы книг на казахском языке. для раздачи использую opentracker.
<!--more-->

[Opentracker](https://erdgeist.org/arts/software/opentracker/) - это очень простой трекер. 
В интернете достаточно ресурсов:

* [как собрать?](https://erdgeist.org/arts/software/opentracker/) 
* [как настроить?](http://i-notes.org/ustanovka-retrekera-na-baze-opentracker/) 

Реализован закрытый режим работы. 

Необходимо создать файл, в котором перечисляются info_hash, которые нужно обслуживать (whitelist), либо которые нужно блокировать (blacklist)

Файл systemd

{% highlight bash %}
[Unit]
Description=opentracker

[Service]
PIDFile=/tmp/opentracker.pid
User=nurmukhamed
Group=nurmukhamed
WorkingDirectory=/tmp
ExecStart=/bin/bash -c '/usr/local/bin/opentracker -f /etc/opentracker.conf -w /etc/opentracker.whitelist'

[Install]
WantedBy=multi-user.target
{% endhighlight%} 

