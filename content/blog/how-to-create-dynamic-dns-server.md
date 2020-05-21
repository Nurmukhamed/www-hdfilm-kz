---
layout: page
title: Реализовано - как реализовать свой динамический днс сервер
date: 2017-02-28
comments: true
published: true
categories:
  - dns
  - ddns
  - yandex dns api
  - github
  - travis-ci
  - gpg
---

В голову пришла идея - как реализовать свой динамический днс сервер, используя доступные услуги.
<!--more-->

## Предыстория

У меня с 2005 года были домашние сервера. Для них я использовал различные ddns-решения бесплатные. Но потом эти услуги либо закрылись, либо стали платными. В последнее время я использую Yandex DNS API для своего домашнего сервера. Открыл домен homeserver.kz, разместил в Yandex. Для обновления использую скрипт, который нашел в интернете. 

Но есть одна проблема. Допустим, у меня и моего брата есть домашние сервера. Я создаю две dns-записи для себя и брата, использую один скрипт для обновления записей. Оба сервера мне подконтрольны. А что делать, если кто-либо попросил меня создать третью запись? Ведь всем трем серверам придется использовать один токен с полным доступом к доменным записям.

Я думал как решить данный вопрос и раньше. Теперь придумал, как это все реализовать безопасным образом.

## Описание

Участники процесса обновления днс-записей:

- домашний сервер ( может быть любой другой компьютер);
- репозитарий на github;
- сервис Travis-CI, подключенный к репозитарию;
- сервис Yandex DNS API
- ключи gpg для безопасного обмена сообщениями.

Алгоритм работы:

- ****Домашний сервер****
	- создает gpg-ключи;
	- получает свой внешний ip-адрес;
	- загружает (push) себе репозитарий с гитхаба;
	- изменяет файл serverA.homeserver.kz - содержание файла - ip-адрес (предположение);
	- делает коммит в репозиторий, подписывает своим gpg-ключом;
	- выгружает (pull) репозитарий в гитхаб;
- ****Github****
	- получив изменения от сервера, вызывает сервис Travis-CI;
- ****Travis-CI****
	- запускает докер-контейнер;
	- настраивает gpg;
    - настраивает таблицу соответствия - имяфайла - gpg-ключ; 
    - находит измененные файлы;
    - проверяет, кто создал файл;
    - проверяет, что текст файла - только ip-адрес
    - вызывает скрипт обновления днс-записи в Yandex DNS API;
- ****Yandex DNS****
	- производит обновление записи;
    
Вот от руки нарисовал как должен работать алгоритм

{% img https://s3-eu-west-1.amazonaws.com/images.hdfilm.kz/dynamic_dns_yandex_github_travis_ci.jpg %}

## Домашний сервер

Узнал, что в git уже встроен функционал проверки коммитов через подписи gpg. Очень помогло прочтение следующих статей:

- [Signing Git commits with GPG](https://blog.thibmaekelbergh.be/2016/11/29/signing-git-commits-with-gpg.html)
- [Github : Signing commits using GPG (Ubuntu/Mac)](https://gist.github.com/ankurk91/c4f0e23d76ef868b139f3c28bde057fc)
- [A Git Horror Story: Repository Integrity With Signed Commits](https://mikegerwitz.com/papers/git-horror-story)
- [Automatic Git GPG Signing ](http://oloflarsson.se/automatic-git-gpg-signing/).

****Предостережние**** - Создайте отдельного пользователя для обновления, не используйте свой gpg-ключ для обновления.

****Создаем пользователя****

```
useradd yandex-dns-updater
passwd yandex-dns-updater

su - yandex-dns-updater
```

********
****Создаем ключи ssh для github****

```
mkdir ~/.ssh
chmod 700

ssh-keygen -f github
mv github github.pub ~/.ssh
chmod 600 ~/.ssh/github*
cat ~/.ssh/config
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github

```

****Создаем GPG-ключ****

```
#
# create new gpg key,
# username main.homeserver.kz
# email main@homeserver.kz
#
gpg --gen-key
# save this file to some place, will used later
gpg --export --armor GPGKEYID > gpgkeyid.txxt

```

****Настройки Git****

```
# setting for git 
git config --global user.name "Main.Homeserver.kz"
git config --global user.email "main@homeserver.kz"

# setting for git and gpg 
git config commit.gpgsign true
git config --global user.signingkey GPGKEYID
git config gpg.program /home/yandex-dns-updater/autogpg.sh
```

****GPG-Прокси для Git****

```
# gpg proxy 
cat /home/yandex-dns-updater/autogpg.sh
#!/bin/bash

gpg --batch --no-tty --yes --passphrase GPGKEYPASSWD $@ <&0

# Finally we exit with the same code as gpg.
exit $?

```

****Создаем новый репозиторий****

```
# create repo for updater
mkdir github
cd github
git init 

git remote add origin git@github.com:USERNAME/yandex-dns-api-updater.git

git pull 

# get my external ip from myextenralip.com
curl -o main.txt http://myexternalip.com/raw

git commit -S -m "Main.Homeserver.kz ip-address is changed at $(date)"

git push -u origin master

```

****Скрипт - обновление данных****

```
#!/usr/bin/env bash
#
# This is update script, cron it.
#

REPO=/PATH/TO/YOUR/GITHUB/REPOSITORY
NAME=main

cd ${REPO}

# get external ip address
curl -o ${NAME}.txt http://myexternalip.com/raw

# check if file is changed
CHANGED=$(git status --porcelain|grep ${NAME}.txt)

if [ -n "${CHANGED}" ]; then
	git pull
    echo "IP address is changed, pushing new data to remote repository"
	git add ${NAME}.txt
	git commit -S -m "new ip-addres at $(date)"
	git push -u origin master
else
	echo "IP address is not changed"
fi
```

## Travis-Ci
Для работы с тревисом рекомендую создать нового пользователя или создать новый контейнер docker. Я использую новый контейнер.

****Создаем новый контейнер****

```
sudo docker run -it --name travis centos /bin/bash
```

****Устанавливаем необходимые пакеты****

```
yum install ruby gem gpg vim rsync -y
gem install travis
travis login
mkdir /travis
```

****Создаем gpg-ключи****

```
gpg --gen-key
gpg --import /tmp/main_homeserver_kz_gpg_key.txt
gpg --editkey main_homeserver_kz_gpg_key_id
trust
save
quit

```

Файл data.txt хранит в себе данные для обновления записи:

- токен, [token](https://habrahabr.ru/post/129600/);
- имя домена, [domainname](https://habrahabr.ru/post/129600/);
- время жизни, [ttl](https://habrahabr.ru/post/129600/);
- имя поддомена, [subdomain](https://habrahabr.ru/post/129600/);
- номер записи, [record_id](https://habrahabr.ru/post/129600/);
- номер gpg-ключа, gpg_key_id.

****Файл данных для обновления днс-записей****

```
cd /travis
rsync -avz /root/.gnupg/ .gnupg/
echo "0123456789ABCDEF01234567890ABCDEF0123456789ABCDEF012:domain.kz:900:subdomain:record_id:gpg_key_id" > data.txt
```

****Подготовка зашифрованных данных****

```
tar cvf encryptedfiles.tar .gnupg data.txt
travis encrypt-file encryptedfiles.tar -r Username/repository
```

****encryptedfiles.tar.enc**** следует сохранить в репозитории на гитхабе. 

Как работать с тревис, можно узнать в [этой статье](http://www.hdfilm.kz/blog/2017/01/24/Moving-to-GitHub-Travis/). Также вам понадобится мой [репозиторий](https://github.com/Nurmukhamed/yandex-dns-api-updater) для ознакомления.

