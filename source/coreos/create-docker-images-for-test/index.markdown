---
layout: page
title: "CoreOS: Создание контейнеров для тестовой площадки"
date: 2015-02-25 15:46
comments: true
sharing: true
footer: true
categories: [centos, coreos, docker, docker registry, vmware, esxi]
previous: "coreos/docker-base-tools"
next: "coreos/setting-services-in-coreos"
---

**Введение**

Создать контейнеры для docker можно двумя способами:

*   ручное
*   через dockerfile

В данное время будем рассматривать только ручное создание. Для создания контейнеров используем Developers.

**Контейнеры**

*curl*

Запустить контейнер centos-base-with-localrepo - базовый контейнер, использующий
локальные репозитории

{% codeblock lang:bash %}
docker run -i -t hub.nurm.local:5000/centos-base-with-localrepo /bin/bash

{% endcodeblock %}

Создать скрипт - бесконечный цикл, запрашивающий страницу

{% codeblock lang:bash %}
cat <<EOF > /root/curl_loop.sh
#!/bin/bash

CURL=/usr/bin/curl
#echo $CURL

while true
do
        $CURL -silent http://a.haproxy.nurm.local/counter.php > /dev/null
        sleep 300
done
EOF

chmod + x /root/curl_loop.sh
{% endcodeblock %}

Сохранить изменения, загрузить образ в репозиторий

{% codeblock lang:bash %}
docker commit ${CONTAINER_ID} centos-test-curl
docker tag ${IMAGE_ID} hub.nurm.local:5000/centos-test-curl
docker push hub.nurm.local:5000/centos-test-curl
{% endcodeblock %}

*haproxy*

Запустить контейнер centos-base-with-localrepo - базовый контейнер, использующий
локальные репозитории

{% codeblock lang:bash %}
docker run -i -t hub.nurm.local:5000/centos-base-with-localrepo /bin/bash

{% endcodeblock %}

Установить балансировщик нагрузки haproxy

{% codeblock lang:bash %}
yum install haproxy

cat <<EOF > /etc/haproxy/haproxy.cfg
global
    maxconn 4096

defaults
    log global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    redispatch
    maxconn 2000
    contimeout  5000
    clitimeout  50000
    srvtimeout  50000

frontend http-in
    bind *:80
    default_backend http

backend http
    server a-httpd 192.168.254.207:80 maxconn 32
    server b-httpd 192.168.254.208:80 maxconn 32
    server c-httpd 192.168.254.209:80 maxconn 32
EOF

{% endcodeblock %}

Сохранить изменения, загрузить образ в репозиторий

{% codeblock lang:bash %}
docker commit ${CONTAINER_ID} centos-test-haproxy
docker tag ${IMAGE_ID} hub.nurm.local:5000/centos-test-haproxy
docker push hub.nurm.local:5000/centos-test-haproxy
{% endcodeblock %}



*httpd*

Запустить контейнер centos-base-with-localrepo - базовый контейнер, использующий
локальные репозитории

{% codeblock lang:bash %}
docker run -i -t hub.nurm.local:5000/centos-base-with-localrepo /bin/bash
{% endcodeblock %}

Установить вебсервер с поддержкой php, загрузить [простейший счетчик посещений](https://github.com/ajay-gandhi/simphp)

{% codeblock lang:bash %}
yum install httpd php

curl http://dnsmasq/simphp.php -o /var/www/html/simphp.php

cat <<EOF > /var/www/html/counter.php
<?php require("simphp.php"); ?>

<p class="hits"><?php echo $info; ?></p>

EOF

chown apache:root -R /var/www/
{% endcodeblock %}

Сохранить изменения, загрузить образ в репозиторий

{% codeblock lang:bash %}
docker commit ${CONTAINER_ID} centos-test-httpd
docker tag ${IMAGE_ID} hub.nurm.local:5000/centos-test-httpd
docker push hub.nurm.local:5000/centos-test-httpd

{% endcodeblock %}


