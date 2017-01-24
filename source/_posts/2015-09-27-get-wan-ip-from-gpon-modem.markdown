---
layout: post
title: "Как получить адрес Wan с gpon-модема Alcatel-Lucent"
date: 2015-09-27 04:36:08 +0000
comments: true
categories: 
- linux
- curl
- sed
- grep
- dyndns
- gpon
- alcatel-lucent

---

<!-- more -->

В процессе настройки dyndns для домашнего сервера нужно было узнать свой внешний адрес. Решений было 2

*   Получить адрес используя сторонний сайт, такой как [ifconfig](http://ifconfig.me)
*   Получить адрес используя веб-страницу модема.


Я использовал оба варианта, но в первом варианте была проблема - очень долгая задержка. Поэтому принял решение, использовать второй вариант.

**Как получить адрес?**

{% codeblock %}
curl --silent --user USERNAME:USERPASS http://ROUTERID/html/wan.html
{% endcodeblock %}

Мы получим страницу со всеми настройками модема.

{% codeblock %}
sed -n '/<!-- DYNAMIC IP -->/,/<!-- end DYNAMIC IP -->/p'
{% endcodeblock %}

Вырежем нужные нам настройки - Динамический IP.

{%  codeblock %}
 sed -n '/IP Address/,/<\/tr>/p'
{% endcodeblock %}

Вырежем таблицу IP-адреса

{% codeblock %}
grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}"
{% endcodeblock %}

Испольуем grep, вытаскиваем сам ip-адрес.

Сложим все вместе

{% codeblock %}
current_ip=$(curl --silent --user USERNAME:USERPASS http://192.168.1.1/html/wan.html | sed -n '/<!-- DYNAMIC IP -->/,/<!-- end DYNAMIC IP -->/p'| sed -n '/IP Address/,/<\/tr>/p'|grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
{% endcodeblock %}

