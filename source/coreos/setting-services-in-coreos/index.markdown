---
layout: page
title: "CoreOS: Настройка сервисов в кластере CoreOS"
date: 2015-02-25 15:46
comments: true
sharing: true
footer: true
categories: [centos, coreos, docker, docker registry, vmware, esxi]
previous: "coreos/create-docker-images-for-test"
next: "coreos/start-services-testing"
---

**Введение**

Рекомендую ознакомиться со [следующей инструкцией](https://www.digitalocean.com/community/tutorial_series/getting-started-with-coreos-2).
Очень подробное описание как работать с CoreOS.

**Подключение к кластеру**

Подключаемся к любому узлу кластера, я создал пользователя nurmukhamed.

{% codeblock lang:bash %}
    slogin nurmukhamed@a.coreos.nurm.local
{% endcodeblock %}

**Создание конфигурационных файлов**

Создайте следующие файлы

*a.httpd*

{% codeblock lang:bash %}
cat <<EOF > a-httpd.service

[Unit]
Description=A.HTTPD service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill a-httpd
ExecStartPre=-/usr/bin/docker rm a-httpd
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-httpd
ExecStartPre=/usr/bin/ip a add 192.168.254.207/25 dev vlan501
ExecStart=/usr/bin/docker run --name a-httpd -p 192.168.254.207:80:80 hub.nurm.local:5000/centos-test-httpd /usr/sbin/apachectl -D FOREGROUND
ExecStop=/usr/bin/docker kill a-httpd
ExecStop=/usr/bin/ip ad del 192.168.254.207/25 dev vlan501

[X-Fleet]
X-Conflicts=b-httpd.service, c-httpd.service, a-haproxy.service
EOF

{% endcodeblock %}

*b.httpd*

{% codeblock lang:bash %}
cat <<EOF > b-httpd.service

[Unit]
Description=B.HTTPD service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill b-httpd
ExecStartPre=-/usr/bin/docker rm b-httpd
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-httpd
ExecStartPre=/usr/bin/ip a add 192.168.254.208/25 dev vlan501
ExecStart=/usr/bin/docker run --name b-httpd -p 192.168.254.208:80:80 hub.nurm.local:5000/centos-test-httpd /usr/sbin/apachectl -D FOREGROUND
ExecStop=/usr/bin/docker kill b-httpd
ExecStop=/usr/bin/ip ad del 192.168.254.208/25 dev vlan501

[X-Fleet]
X-Conflicts=a-httpd.service, c-httpd.service, a-haproxy.service
EOF

{% endcodeblock %}

*c.httpd*

{% codeblock lang:bash %}
cat <<EOF > c-httpd.service

[Unit]
Description=C.HTTPD service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill c-httpd
ExecStartPre=-/usr/bin/docker rm c-httpd
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-httpd
ExecStartPre=/usr/bin/ip a add 192.168.254.209/25 dev vlan501
ExecStart=/usr/bin/docker run --name c-httpd -p 192.168.254.209:80:80 hub.nurm.local:5000/centos-test-httpd /usr/sbin/apachectl -D FOREGROUND
ExecStop=/usr/bin/docker kill c-httpd
ExecStop=/usr/bin/ip ad del 192.168.254.209/25 dev vlan501

[X-Fleet]
X-Conflicts=a-httpd.service, b-httpd.service, a-haproxy.service
EOF

{% endcodeblock %}

*a.haproxy*

{% codeblock lang:bash %}
cat <<EOF > a-haproxy.service
[Unit]
Description=A.HAPROXY service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill a-haproxy
ExecStartPre=-/usr/bin/docker rm a-haproxy
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-haproxy
ExecStartPre=/usr/bin/ip a add 192.168.254.210/25 dev vlan501
ExecStart=/usr/bin/docker run --name a-haproxy -p 192.168.254.210:80:80 hub.nurm.local:5000/centos-test-haproxy /usr/sbin/haproxy -q -f /etc/haproxy/haproxy.cfg
ExecStop=/usr/bin/docker kill a-haproxy
ExecStop=/usr/bin/ip ad del 192.168.254.210/25 dev vlan501

[X-Fleet]
X-Conflicts=a-httpd.service, b-httpd.service, c-httpd.service
EOF
{% endcodeblock %}

*a.curl*

{% codeblock lang:bash %}
cat <<EOF > a-curl.service
[Unit]
Description=A.CURL service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill a-curl
ExecStartPre=-/usr/bin/docker rm a-curl
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-cu                                                                                                                                                             rl
ExecStart=/usr/bin/docker run --name a-curl hub.nurm.local:5000/cent                                                                                                                                                             os-test-curl /root/curl_loop.sh
ExecStop=/usr/bin/docker kill a-curl

EOF
{% endcodeblock%}

*b.curl*

{% codeblock lang:bash %}
cat <<EOF > b-curl.service
[Unit]
Description=B.CURL service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill b-curl
ExecStartPre=-/usr/bin/docker rm b-curl
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-curl
ExecStart=/usr/bin/docker run --name b-curl hub.nurm.local:5000/centos-test-curl /root/curl_loop.sh
ExecStop=/usr/bin/docker kill b-curl

EOF
{% endcodeblock %}

*c.curl*

{% codeblock lang:bash %}
cat <<EOF > c-curl.service
[Unit]
Description=C.CURL service
After=etcd.service
After=docker.service

[Service]
TimeoutStartSec=0
KillMode=none
ExecStartPre=-/usr/bin/docker kill c-curl
ExecStartPre=-/usr/bin/docker rm c-curl
ExecStartPre=/usr/bin/docker pull hub.nurm.local:5000/centos-test-curl
ExecStart=/usr/bin/docker run --name c-curl hub.nurm.local:5000/centos-test-curl /root/curl_loop.sh
ExecStop=/usr/bin/docker kill c-curl

EOF
{% endcodeblock %}


*Загрузка конфигурационных файлов*

{% codeblock lang:bash %}
    fleetctl submit a-httpd.service b-httpd.service c-httpd.service
    fleetctl load a-httpd.service b-httpd.service c-httpd.service

    fleetctl submit a-haproxy.service
    fleetctl load a-haproxy.service

    fleetctl submit a-curl.service b-curl.service c-curl.service
    fleetctl load a-curl.service b-curl.service c-curl.service

{% endcodeblock %}

*Запуск контейнеров*

{% codeblock lang:bash%}
    fleetctl start a-httpd.service b-httpd.service c-httpd.service
    fleetctl start a-haproxy.service
    fleetctl start a-curl.service b-curl.service c-curl.service
{% endcodeblock %}

*Проверка*

{% codeblock lang:bash%}
    fleetctl list-unit-files
    fleetctl list-units

    curl http://a.haproxy.nurm.local/counter.php
    curl http://a.httpd.nurm.local/counter.php
    curl http://b.httpd.nurm.local/counter.php
    curl http://c.httpd.nurm.local/counter.php
{% endcodeblock %}

Если нет ошибок, вебсервера должны выдать страницу, подобно этой

{% codeblock lang:html %}

<p class="hits">Hits: 84<br \>Unique Visits: 4</p>


{% endcodeblock %}



