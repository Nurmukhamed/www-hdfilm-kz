---
layout: post
title: "Установка Iredmail-почтового сервера как шлюз перед Exchange"
date: 2017-02-07 12:30:30 +0600
comments: true
categories: 
- centos
- postfix
- iredmail
- active directory
- let's encrypt
- dkim
- spf
---

# Установка Iredmail-почтового сервера как шлюз перед Exchange

Опишу здесь свой опыт настройки  Iredmail для работы с Exchange <!--more-->

## Требования

Требуется настроить почтовый сервер как шлюз перед Exchange:
- Должна быть поддержка antispam-решения
- Должна быть поддержка greylist-решения
- Должна быть поддержка DKIM-решения
- Должна быть поддержка Active Directory
- Список пользователей должен выгружаться из Active Directory
- Список групп должен выгружаться из Active Directory

## Что подходит
Я выбрал Iredmail как решение наиболее подходящее. Из коробки поддерживает antispam, antivirus, greylist, DKIM, spf. Есть бакэнд для работы с LDAP-серверами, в том числе с Active Directory. На сайте присутствует полная информация по настройке.

## Установка
Для установки мне предоставили сервер на базе CentOS 6.2. Сервер был обновлен до последней версии 6.8.

### DNSMASQ
Я считаю, что на почтовом сервере должен работать кэширующий днс-сервер. я выбрал DNSMASQ, ниже мой конфиг

{% highlight bash %}

[root@mail ~]# cat /etc/dnsmasq.conf 
conf-dir=/etc/dnsmasq.d

[root@mail ~]# cat /etc/dnsmasq.d/activedirectory.conf 
server=/mydomain.kz/192.168.1.1
server=/mydomain.kz/192.168.1.2
server=/mydomain.kz/192.168.1.3
server=/1.168.192.in-addr.arpa/192.168.1.1
server=/1.168.192.in-addr.arpa/192.168.1.2
server=/1.168.192.in-addr.arpa/192.168.1.3

[root@mail ~]# cat /etc/dnsmasq.d/dns.conf 
no-dhcp-interface=eth0
interface=lo

[root@mail ~]# cat /etc/dnsmasq.d/resolvfile.conf 
resolv-file=/etc/resolv.conf.dnsmasq

[root@mail ~]# cat /etc/resolv.conf.dnsmasq 
nameserver 8.8.8.8
search mydomain.kz 

{% endhighlight %}

DNSMASQ знает где находятся сервера Active Directory, все остальные запросы отправляет в днс-сервер Гугла.

### Iredmail + Active Directory

Iredmail устанавливается с поддержкой LDAP, затем [по этой статье](http://www.iredmail.org/docs/active.directory.html) настраиваем поддержку Active Directory.

В нашем решение нам не нужно было настраивать dovecot, webmail, так что эти разделы можно пропустить.

но есть отличие о которых я хотел написать.

### Настройка транспорта для postfix

{% highlight bash %}
[root@mail postfix]# postconf|grep transport_maps
transport_maps = hash:/etc/postfix/transport
[root@mail postfix]# cat /etc/postfix/transport
mydomain.kz smtp:[192.168.1.4]:25
{% endhighlight %}

### Настройка ldap

{% highlight bash %}
[root@mail postfix]# postconf |grep ldap
smtpd_sender_login_maps = proxy:ldap:/etc/postfix/ad_sender_login_maps.cf
virtual_alias_maps = proxy:ldap:/etc/postfix/ad_virtual_alias_maps.cf, proxy:ldap:/etc/postfix/ad_virtual_group_maps.cf
virtual_mailbox_maps = proxy:ldap:/etc/postfix/ad_virtual_mailbox_maps.cf

[root@mail postfix]# cat /etc/postfix/ad_sender_login_maps.cf 
server_host     = srv01.mydomain.kz
server_port     = 389
version         = 3
bind            = yes
start_tls       = yes
tls_ca_cert_file= /etc/pki/tls/certs/mydomain.der
bind_dn         = username
bind_pw         = password
search_base     = dc=mydomain,dc=kz
scope           = sub
query_filter    = (&(userPrincipalName=%s)(objectClass=person)(!(userAccountControl:1.2.840.113556.1.4.803:=2)))
result_attribute= userPrincipalName
debuglevel      = 0

[root@mail postfix]# cat /etc/postfix/ad_virtual_alias_maps.cf 
server_host     = srv01.mydomain.kz
server_port     = 389
version         = 3
bind            = yes
start_tls       = yes
tls_ca_cert_file= /etc/pki/tls/certs/mydomain.der
bind_dn         = username
bind_pw         = password
search_base     = dc=mydomain,dc=kz
scope           = sub
query_filter    = (&(objectClass=person)(mail=%s))
result_attribute= mail
debuglevel      = 0

[root@mail postfix]# cat /etc/postfix/ad_virtual_group_maps.cf 
server_host     = srv01.mydomain.kz
server_port     = 389
version         = 3
bind            = yes
start_tls       = yes
tls_ca_cert_file= /etc/pki/tls/certs/mydomain.der
bind_dn         = username
bind_pw         = password
search_base     = dc=mydomain,dc=kz
scope           = sub
query_filter    = (&(objectClass=group)(mail=%s))
special_result_attribute = member
leaf_result_attribute = mail
result_attribute= userPrincipalName
debuglevel      = 0

[root@mail postfix]# cat /etc/postfix/ad_virtual_mailbox_maps.cf 
server_host     = srv01.mydomain.kz
server_port     = 389
version         = 3
bind            = yes
start_tls       = yes
tls_ca_cert_file= /etc/pki/tls/certs/mydomain.der
bind_dn         = username
bind_pw         = password
search_base     = dc=mydomain,dc=kz
scope           = sub
query_filter    = (&(objectclass=person)(userPrincipalName=%s))
result_attribute= userPrincipalName
result_format   = %d/%u/Maildir/
debuglevel      = 0
[root@mail postfix]# 

{% endhighlight %}

Данный конфиг помог побороть проблему с пользователями и их емайлами. Основные емайлы имели вид userXXXX@mydomain.kz, использовались только для служебных целей. Для переписки использовались другие alias - name.familyname@mydomain.kz. Стандартный конфиг не мог найти alias, находил только основные емайлы. Пришлось почитать, погуглить. Решение в файле ad_virtual_alias_maps.cf. 

### Поддержка LDAP-TLS
В Windows Server 2012 по умолчанию включен режим tls, даже если обращаться по порту 389, то происходит starttls, и уже в безопасной среде происходит обмен данными. В документации этого документа не было. Решение - попросил Windows-администратора выгрузить мне ca-сертификат, который использует домен. Затем преобразовать его в der-формат, указать в конфиге ldap и postfix использовать tls-режим

{% highlight bash %}
[root@mail ~]# cat /etc/openldap/ldap.conf
HOST srv01.mydomain.kz
PORT    636
TLS_CACERT /etc/pki/tls/certs/mydomain.der
TLS_REQCERT demand

{% endhighlight %}

### Установка Let's Encrypt

Пользуясь случаем установил сертификат let's encrypt. Настраивал [по этой статье](https://habrahabr.ru/post/304174/).

### DKIM, spf

[По этой статье](http://www.iredmail.org/docs/sign.dkim.signature.for.new.domain.html) настроил DKIM, spf. Отправил администратору, что нужно присать в днс-сервере для корректной работы spf, DKIM. проверил через гуглмайл, работает, исходящие письма подписываются.


