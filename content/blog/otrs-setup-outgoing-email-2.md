---
layout: post
title: HOWTO - Настройка исходящей почты для OTRS
date: '2020-12-10 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- centos
- postfix
- yandex
- dkim
- spf
- otrs
---

**Настройка исходящей почты для OTRS** <!--more-->

[Ранее](https://www.hdfilm.kz/blog/2020/06/16/otrs-setup-outgoing-email/), я думал как настроить домашний сервер, чтобы можно было отправлять письма и не попадать в спам. Теперь я нашел правильный путь.

Имеется домашний сервер, подключенный к сети IDNET Kazakhtelecom, адреса выдаются динамически. На сервере установлена и настроена OTRS. Прием входящих сообщений не 
вызывает трудностей. Проблемы с исходящими серверами. Почтовый домен подключен к yandex почте. 

# Шаг №1 - Настройка spf записей 

Нужно перенести почту на yandex.Почту, переносим днс-сервер и почтовый сервер. После успешной настройки, Yandex создаст для домена spf-, dkim-записи. Можно будет свободно через Веб-интерфейс отправлять и принимать почту. Также будут работать smtp-, imap-, pop3-сервисы.

# Шаг №2 - Настройка spf записей 
Мои неудачи были связаны с тем, что я редактировал spf-запись для всего домена. Но, оказалось, нужно еще создавать spf-запись для исходящего сервера. Например, наш домен - edenprime.kz, создадим следующие записи:

| Имя               | Тип | Значение                                   | Динамическое обновление |
|-------------------|-----|--------------------------------------------|-----|
| otrs              | A   | IP-адрес                                   | Да  |
| otrs              | TXT | v=spf1 ip4:$IP include:_spf.yandex.ru ~all | Да  |
| otrs._domainkey   | TXT | v=DKIM1; k=rsa; t=s; s=email; p=PUBLICKEY  | Нет |

В [Connect.Yandex](https://connect.yandex.ru/portal/home) нужно добавить DKIM-запись исходящего сервера. [Здесь подробная инструкция](https://tecadmin.net/setup-domainkeys-dkim-on-postfix-centos-rhel/).

Также возникли проблемы с динамическим обновлением днс-записей, очень помог [этот скрипт](http://linux.bolden.ru/yandex-ddns/). Я немного изменил скрипт под свои нужды.

# Шаг №3 - Настройка таймера для динамического обновления

**Установим необходимый пакет**
```bash
 sudo yum install perl-LWP-Protocol-https
```

**Скрипт нужно разместить в /usr/local/bin/yddns.pl**
```perl
#!/usr/bin/perl

use LWP::UserAgent;

my $current_ip = `curl https://myexternalip.com/raw`;

my %records = (
    otrs => {
        id => "XXXXXXXX",
        content => "$current_ip",
        subdomain => "otrs"
        },
    spf => {
        id => "XXXXXXXX",
        content => "v=spf1 ip4:$current_ip include:_spf.yandex.ru ~all",
        subdomain => "otrs"
    }
);

my $token = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
my $domain = "edenprime.kz"; 
my $TTL = "900"; 
my $uri ="https://pddimp.yandex.ru/api2/admin/dns/edit"; 

for my $record (keys %records) {
        my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );

        my $response = $ua->post( $uri,
                [
                'domain' => $domain,
                'subdomain' => $records{$record}{subdomain},
                'record_id' => $records{$record}{id},
                'content' => $records{$record}{content},
                'TTL' => $TTL,
                ],
                'PddToken' => $token,
        );

        if ( $response->is_success ) {
                print $response->decoded_content;
        } else {
                die $response->status_line;
        }
}
```

**Необходимые файлы для systemd**
```bash
cat<<EOF | sudo tee /etc/systemd/system/yddns.timer
[Unit]
Description=Update otrs.edenprime.kz ip address at yandex dns service

[Timer]
OnCalendar=*:0,15,30,45
AccuracySec=1s

[Install]
WantedBy=timers.target
EOF

cat<<EOF | sudo tee /etc/systemd/system/yddns.service
[Unit]
Description=Update otrs.edenprime.kz ip address at yandex dns service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/yddns.pl

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable --now yddns.timer 
```

# Шаг №4 - Ожидаем обновления

Теперь нужно обновить днс-записи, подождать пока днс-записи обновятся по всему миру, затем можно отправить тестовое письмо на support@edenprime.kz
