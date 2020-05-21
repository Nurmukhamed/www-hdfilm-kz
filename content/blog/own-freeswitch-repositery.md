---
layout: page
title: "Сборка пакетов для репозитория Freeswitch в CentOS 6.8"
date: 2016-07-27
comments: true
categories:
---

# Предыстория

для домашнего сервера нужно сделать систему voip, у меня есть 4 циско-телефона. <!-- more --> с самого начала решил сделать распределенную систему. пока в планах только 3 компонента:

  * asterisk-dongle - виртуальная машина для работы со свистками Huawei
  * freeswitch - виртуальная машина для работы с sip-устройствами.
  * asterisk-main - виртуальная машина - основной узел маршрутизации и прочего.

проблема со freeswitch. не нашел готовых репозиториев.

есть два выхода:

  * собрать на виртуальной машине из исходников
  * собрать сперва rpm, затем установить.

я выбрал второй вариант.

что нам нужно сперва изучить:

  * [отличная статья про утилиту mock](http://blog.packagecloud.io/eng/2015/05/11/building-rpm-packages-with-mock/)
  * [сборка freeswitch под docker](https://github.com/BetterVoice/freeswitch-container)
  * [как собрать свой репозиторий](https://www.stableit.ru/2010/03/centos_24.html)

Шаги:

  * установить виртуальную машину - Centos 6.8
  * установить пакет epel, mock
  * создать пользователя nurmukhamed, под которым будет проводится сборка пакетов
  * установить httpd, настроить папку /var/lib/localrepo
  * собрать пакеты необходимые для freeswitch
  * собрать freeswitch

# Установить пакет epel, mock

```
yum install epel-release -y
yum update -y
yum install mock -y

alias mock='mock -r my-epel-6-x86_64 --enablerepo=localrepo --rebuild'
alias move2repo='mv /var/lib/mock/my-epel6-x86_64/result/*.rpm /var/lib/localrepo; createrepo /var/lib/localrepo'

cp /etc/mock/epel-6-x64_86.cfg /etc/mock/my-epel-6-x86_64.cfg
vim /etc/mock/my-epel-6-x86_64.cfg

```

добавить в конфигурацию mock новый репозиторий

```
[localrepo]
name=localrepo
baseurl=http://localrepo.ip/localrepo/
cost=2000
enabled=0
```
на этом настройка mock закончена.

# Собрать пакеты необходимые для freeswitch

все действия происходят под пользователем builduser. это необходимо, что не затрагивать системные файлы и не засорять систему.

```
## libyuv
cd
git clone https://freeswitch.org/stash/scm/sd/libyuv.git
mv libyuv libyv-0.0.1280
find libyuv-0.0.1280 -type f | grep -i "\.git" | xargs rm
tar cvzf ~/rpmbuild/SOURCES/libyuv-0.0.1280.tar.gz libyuv-0.0.1280
cp libyuv-0.0.1280/libyuv.spec ~/rpmbuild/SPEC
cp libyuv-0.0.1280/libyuv.pc.in ~/rpmbuild/SOURCES
rm -rf libyuv-0.0.1280
cd
rpmbuild -bs ~/rpmbuild/SPEC/libyuv.spec
mock ~/rpmbuild/SRPMS/libyuv-0.0.1280-0.el6.src.rpm
move2repo

## nasm
cd
wget http://www.nasm.us/pub/nasm/releasebuilds/2.12.02/linux/nasm-2.12.02-0.src.rpm -O ~/rpmbuild/SRPMS/nasm-2.12.02.0.src.rpm

mock ~/rpmbuild/SRPMS/nasm-2.12.02.0.src.rpm
cp /var/lib/mock/my-epel-6-x86_64/result/*.rpm /var/lib/localrepo
createrepo /var/lib/localrepo

## libvpx2 diff
diff libvpx2-3.0.0/libvpx.spec ~/rpmbuild/SPECS/libvpx.spec
1c1
< %global majorver 2
---
> %global majorver 3

## libvpx2
cd
git clone https://freeswitch.org/stash/scm/sd/libvpx.git
cp ~/libvpx/libvpx.spec ~/rpmbuild/SPECS
mv ~/libvpx ~/libvpx2-3.0.0
tar -czvf ~/rpmbuild/SOURCES/libvpx2-3.0.0.tar.gz libvpx2-3.0.0
rpmbuild -bs ~/rpmbuild/SPEC/libvpx.spec
mock ~/rpmbuild/SRPMS/libvpx2-3.0.0-1.el6.src.rpm
cp /var/lib/mock/my-epel-6-x86_64/*.rpm /var/lib/localrepo
rm -rf ~/libvpx2-3.0.0

## broadvoice
cd
wget http://files.freeswitch.org/downloads/libs/broadvoice-0.1.0.tar.gz
cd /tmp
tar zxvf broadvoice-0.1.0.tar.gz
cp broadvoice-0.1.0/broadvoice.spec ~/rpmbuild/SPEC
cd
mv broadvoice-0.1.0.tar.gz ~/rpmbuild/SOURCES
rpmbuild -bs ~/rpmbuild/SPEC/broadvoice.spec
mock ~/rpmbuild/SRPMS/broadvoice-0.1.0-1.el6.src.rpm
cp /var/lib/mock/my-epel-6-x86_64/*.rpm /var/lib/localrepo
createrepo /var/lib/repo


## libcodec2
cd
wget http://files.freeswitch.org/downloads/libs/libcodec2-2.59.tar.gz
cd /tmp
tar zxvf ~/libcodec2-2.59.tar.gz
cp libcodec2-2.59/libcodec2.spec ~/rpmbuild/SPEC
mv ~/libcodec2-2.59.tar.gz ~/rpmbuild/SOURCES
rpmbuild -bs ~/rpmbuild/SPEC/libcodec2.spec
mock ~/rpmbuild/SRPMS/libcodec2-2.59-1.el6.src.rpm
move2repo

## libflite
cd
wget http://files.freeswitch.org/downloads/libs/flite-2.0.0.tar.gz
cd /tmp
tar zxvf ~/flite-2.0.0.tar.gz
cp flite-2.0.0/flite.spec ~/rpmbuild/SPEC
mv ~/flite-2.0.0.tar.gz ~/rpmbuild/SOURCES
rpmbuild -bs ~/rpmbuild/SPEC/flite.spec
mock -r my-epel-6-x86_64 --enablerepo=localrepo --rebuild ~/rpmbuild/SRPMS/flite-2.0.0-0.el6.src.rpm
cp /var/lib/mock/my-epel-6-x86_64/*.rpm /var/lib/localrepo
createrepo /var/lib/repo

## ilbc
cd
wget http://files.freeswitch.org/downloads/libs/ilbc-0.0.1.tar.gz
cd /tmp
tar -xzvf ilbc-0.0.1.tar.gz
cp ilbc-0.0.1/ilbc.spec ~/rpmbuild/SPEC
mv ~/ilbc-0.0.1.tar.gz ~/rpmbuild/SOURCES
rpmbuild -bs ~/rpmbuild/SPEC/ilbc.spec
mock ~/rpmbuild/SRPMS/ilbc-0.0.1-0.el6.src.rpm
move2repo
rm -rf /tmp/ilbc-0.0.1

## libmongoc
cd
wget http://files.freeswitch.org/downloads/libs/mongo-c-driver-1.1.0.tar.gz
cd /tmp
tar -xzvf mongo-c-driver-1.1.0.tar.gz
cp mongo-c-driver-1.1.0/build/rpm/mongo-c-driver.spec ~/rpmbuild/SPEC
mv ~/mongo-c-driver-1.1.0.tar.gz ~/rpmbuild/SOURCES
rpmbuild -bs ~/rpmbuild/SPEC/mongo-c-driver.spec
mock ~/rpmbuild/SRPMS/mongo-c-driver-1.1.0-1.el6.src.rpm
move2repo
rm -rf /tmp/mongo-c-driver-1.1.0


## g722_1
cd
wget http://files.freeswitch.org/downloads/libs/g722_1-0.2.0.tar.gz
tar -xzvf g722_1-0.2.0.tar.gz
cp g722_1-0.2.0/g722_1.spec ~/rpmbuild/SPEC/
mv g722_1-0.2.0.tar.gz ~/rpmbuild/SOURCES
rpmbuild -bs ~/rpmbuild/SPEC/g722_1.spec
mock ~/rpmbuild/SRPMS/g722_1-0.2.0-1.el6.src.rpm
move2repo

## libsilk
# Install libsilk-dev
cd
wget http://files.freeswitch.org/downloads/libs/libsilk-1.0.8.tar.gz
cd /tmp
tar xzvf libsilk-1.0.8.tar.gz
cp libsilk-1.0.8/libsilk.spec ~/rpmbuild/SPEC
cd
mv libsilk-1.0.8.tar.gz ~/rpmbuild/SPEC
rpmbuild -bs ~/rpmbuild/SPEC/libsilk.spec
mock ~/rpmbuild/SRPMS/libsilk-1.0.8-1.el6.src.rpm
move2repo
rm -rf /tmp/libsilk-1.0.8

## soundtouch
cd
git clone https://freeswitch.org/stash/scm/sd/libsoundtouch.git
mv libsoundtouch soundtouch-1.7.1
find soundtouch-1.7.1 -type f | grep -i "\.git" | xargs rm
cp soundtouch-1.7.1/redhat/soundtouch.spec ~/rpmbuild/SPECS
cp soundtouch-1.7.1/redhat/*.patch ~/rpmbuild/SOURCES
tar cvzf ~/rpmbuild/SOURCES/soundtouch-1.7.1.tar.gz soundtouch-1.7.1
rpmbuild -bs ~/rpmbuild/SPECS/soundtouch.spec
mock ~/rpmbuild/SRPMS/soundtouch-1.7.1-1.el6.src.rpm
move2repo
```

Сборка вспомогательных пакетов завершена.

# Сборка Freeswitch

```
cd
git clone https://freeswitch.org/stash/scm/fs/freeswitch.git -b v1.6.9
cp freeswitch/freeswitch.spec ~/rpmbuild/SPEC/freeswitch.spec
mv freeswitch freeswitch-1.7.0
find freeswitch/ -type f | grep -i "\.git" | xargs rm

tar czf ~/rpmbuild/SOURCES/freeswitch-1.7.0.tar.gz freeswitch-1.7.0
for file in $(cat ~/rpmbuild/SPECS/freeswitch.spec| grep "Source"|grep -v -e "Source0"| awk '{ print $2}'); do; echo $file; wget $file; done;
mv *.tar.* ~/rpmbuild/SOURCES
vi ~/rpmbuild/SPEC/freeswitch.spec
rpmbuild -bs ~/rpmbuild/SPEC/freeswitch.spec
mock ~/rpmbuild/SRPMS/freeswitch-1.6.9-0.el6.src.rpm
move2repo
```

Теперь у нас есть репозиторий пакетов для CentOS-6. можно разворачивать freeswitch, без необходимости компиляции из исходников сырцов.

Также выложил на github файлы, которые я использовал в работе
https://github.com/Nurmukhamed/centos-freeswitch-repo-building-guide/tree/master/etc/mock

