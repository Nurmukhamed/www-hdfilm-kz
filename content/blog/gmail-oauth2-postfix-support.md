---
layout: post
title: Включаем поддержку oauth2 в postfix для работы с Gmail
date: '2020-06-16 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- centos
- postfix
- gmail
- oauth2
- cyrus-sasl
---

**Включаем поддержку oauth2 в postfix для работы с Gmail** <!--more-->

# Почему?

В 2021 Google перейдет на oauth2 режим аутентификации, в связи с этим я решил заранее обновить настройки на своих серверах.

* На всех серверах postfix работает режиме [null-client](http://www.postfix.org/MULTI_INSTANCE_README.html);
* Настроен relayhost на [gmail](https://devops.ionos.com/tutorials/configure-a-postfix-relay-through-gmail-on-centos-7/) с использованием механизма cyrus-sasl-plain;
* Приложения используют sendmail для отправки почтовых сообщений.

Изменения:

* Нужно собрать пакет [cyrus-sasl-xoauth2](http://repo.edenprime.kz/7/x86_64/cyrus-sasl-xoauth2-0.2-1.el7.x86_64.rpm), здесь [src.rpm](http://repo.edenprime.kz/7/SRPMS/cyrus-sasl-xoauth2-0.2-1.el7.src.rpm);
* Нужно собрать пакет [fetchmail-oauth2](http://repo.edenprime.kz/7/x86_64/fetchmail-oauth2-0.1-1.el7.x86_64.rpm), здесь [src.rpm](http://repo.edenprime.kz/7/SRPMS/fetchmail-oauth2-0.1-1.el7.src.rpm);
* Нужно настроить fetchmail-oauth2;
* Нужно получить [первичный токен](http://mmogilvi.users.sourceforge.net/software/oauthbearer.html);
* Нужно изменить настройки postfix;
* Нужно настроить регулярное обновление токенов через systemd timers.

# Установка пакетов

```
cd /tmp
wget http://repo.edenprime.kz/7/x86_64/cyrus-sasl-xoauth2-0.2-1.el7.x86_64.rpm
wget http://repo.edenprime.kz/7/x86_64/fetchmail-oauth2-0.1-1.el7.x86_64.rpm

sudo yum localinstall cyrus-sasl-xoauth2-0.2-1.el7.x86_64.rpm fetchmail-oauth2-0.1-1.el7.x86_64.rpm -y
```

# Настройка fetchmail-oauth2

При установке пакета устанавливаются следующие файлы/каталоги:

* /etc/fetchmail-oauth2
* /usr/bin/fetchmail-oauth2.py
* /usr/bin/googleAuthenticator
* /usr/share/fetchmail-oauth2/lockedMake
* /usr/share/fetchmail-oauth2/Makefile
* /usr/share/fetchmail-oauth2/fetchmail-oauth2.timer
* /usr/share/fetchmail-oauth2/fetchmail-oauth2.service
* /usr/share/fetchmail-oauth2/main.cf
* /usr/share/fetchmail-oauth2/tls_policy
* /usr/share/fetchmail-oauth2/relayhost_map
* /usr/share/fetchmail-oauth2/saslpass
* /usr/share/fetchmail-oauth2/simple.cfg

Это было сделано специально, чтобы у вас была возможность самостоятельно настроить пакет под ваши нужды и чтобы пакет не конфликтовал с другими пакетами.

Разместим файлы и поместим их в нужные места.


# Config file

Необходимо скопировать файл /usr/share/fetchmail-oauth2/simple.cfg в /etc/fetchmail-oauth2/simple.cfg.
Нужно вставить в файл simple.cfg значения **client_id**, **client_secret**.

# Initial token - Первичный токен

Теперь нам нужно получить refresh token и access token. Для этого нам необходимо запустить следующую команду:

```
/usr/bin/fetchmail-oauth2.py -c /etc/fetchmail-oauth2/simple.cfg --obtain_refresh_token_file
```

# Systemd timer and service

Вместо cron будем использовать systemd timer. Также, если у вас другое имя конфигурационного файла (/etc/fetchmail-oauth2/simple.cfg), то вам нужно изменить файл fetchmail-oauth2.service.

Таймер настроен на запуск в 45 минут каждого часа, при необходимости вы можете изменить это значение в файле /etc/systemd/system/fetchmail-oauth2.timer

```
echo "Setting systemd timer and service

sudo cp /usr/share/fetchmail-oauth2/fetchmail-oauth2.* /etc/systemd/system/
sudo systemctl enable fetchmail-oauth2.timer
```

# Настройка Postfix

Предполагается, что настройки postfix по умолчанию. Если же у вас уже внесены изменения в postfix, то внимательно ознакомьтесь с содержимым файла /usr/share/fetchmail-oauth2/main.cf.

Скопируем необходимые файлы 
```
sudo cp /usr/share/fetchmail-oauth2/main.cf         /etc/postfix
sudo cp /usr/share/fetchmail-oauth2/tls_policy      /etc/postfix
sudo cp /usr/share/fetchmail-oauth2/relayhost_map   /etc/postfix
sudo cp /usr/share/fetchmail-oauth2/saslpass        /etc/postfix
sudo cp /usr/share/fetchmail-oauth2/lockedMake      /etc/postfix
sudo cp /usr/share/fetchmail-oauth2/Makefile        /etc/postfix
```

Изменим имя машины и имя домена

```
sudo sed -i 's%myhostname = myhost.example.com%myhostname = alpha.domain.kz%' /etc/postfix/main.cf
sudo sed -i 's%mydomain = example.commy%domain = example.kz%' /etc/postfix/main.cf
```

Теперь нужно внести изменения в содержимое Makefile. Значение XOAUTH2_MAP привести к следующему виду.

```
XOAUTH2_MAP = \
   [smtp.gmail.com]:587~alpha@domain.kz~/etc/fetchmail-oauth2/accesstoken

```

Если у вас больше одной учетной записи нужно дописать в несколько строк.

Нужно перезапустить postfix

```
sudo systemctl restart postfix
sudo systemctl status postfix
```

# Проверка 

```
sudo yum install mailx
echo "Hello world $(date)" | mail -s "test message" bravo@domain.kz

sudo tail /var/log/maillog
```

Если не заработало, смотрим в логи, дебажим и устраняем ошибки.


