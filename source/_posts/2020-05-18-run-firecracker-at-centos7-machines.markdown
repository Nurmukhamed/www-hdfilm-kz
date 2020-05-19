---
layout: post
title: Настройка Firecracker на CentOS 7
date: '2020-05-18 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- centos
- amazon
- virtualization
- kvm
- firecracker
- systemd
- manual
---

**Настройка Firecracker на CentOS 7** <!--more-->


В этой статье хочу рассказать вам настроить [Firecracker](https://github.com/firecracker-microvm/firecracker/) на CentOS 7.

Firecracker - *это технология виртуализации с открытым исходным кодом, предназначенная для создания и управления защищенными, мультитенантными контейнерными и функциональными сервисами, обеспечивающими бессерверные операционные модели. Firecracker запускает рабочие нагрузки в облегченных виртуальных машинах, называемых microVMs, которые сочетают свойства безопасности и изоляции, предоставляемые технологией аппаратной виртуализации, со скоростью и гибкостью контейнеров.*

## План работ

* Вступительное слово;
* Обсуждение архитекутуры;
* Сборка пакета;
* Сборка ядра;
* Сборка корневой системы;
  * Сборка CentOS;
  * Сборка Debian;
  * Сборка Ubuntu; 
* Создание параметризированной службы systemd;
* Шаблон виртуальной машины;
* Настройка сети;
* Настройка firewalld;
* Запуск виртуальной машины;
* Автоматизация действий;
* Примеры:
  * CentOS;
  * Debian;
  * Ubuntu;
* Дальнейшие действия. 

## Вступительное слово

*АВТОР ПРЕДОСТАВЛЯЕТ СТАТЬЮ “КАК ЕСТЬ” БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ, ПОДРАЗУМЕВАЕМЫМИ ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ И ПРИГОДНОСТИ ДЛЯ ОПРЕДЕЛЕННОЙ ЦЕЛИ. ВЕСЬ РИСК, СВЯЗАННЫЙ С КАЧЕСТВОМ И ЭФФЕКТИВНОСТЬЮ СТАТЬИ, ЛЕЖИТ НА ВАС. ЕСЛИ СОДЕРЖАНИЕ СТАТЬИ ОКАЖЕТСЯ НЕВЕРНЫМ, ВЫ БЕРЕТЕ НА СЕБЯ РАСХОДЫ НА ВСЕ НЕОБХОДИМОЕ ОБСЛУЖИВАНИЕ, РЕМОНТ ИЛИ ИСПРАВЛЕНИЕ.*

## Обсуждение архитекутуры

**Firecracker** - это очень простой гипервизор, для запуска виртуальной машины необходимо всего 3 файла:

* Бинарный файл firecracker;
* Специально собранное ядро Linux;
* Сборка корневой системы.

Данная статья описывает как *"правильно приготовить"* firecracker для ОС RHEL/CentOS, в частности для 7 версии. Будут использоваться только стандартные пакеты и утилиты, не будет никаких *"костылей"*. 

Для firecracker будет собран пакет RPM, с соблюдением требований, пакет не должен влиять на другие пакеты, затирать / изменять файлы.

TODO - Планируется внедрение политик Selinux для более безопасной эксплуатации.

Наше дерево файлов и каталогов:

| Путь                                          | Описание                            | TODO  |
|-----------------------------------------------|-------------------------------------|---|
| /usr/lib/systemd/system/firecracker@.service  | Параметризированная служба systemd  | Сделано  |
| /etc/firecracker                              | Каталог для хранения конфигурации виртуальных машин  | Сделано  |
| /usr/sbin/firecracker  | Бинарный файл  | Сделано  |
| /usr/sbin/jailer | Бинарный файл | Сделано|
| /usr/share/firecracker/scripts | Каталог для хранения дополнительных скриптов | Сделано|
| /var/lib/firecracker | Каталог для хранения данных| Сделано |
| /var/lib/firecracker/kernels | Каталог для хранения ядер Linux | Сделано |
| /var/lib/firecracker/rootfs | Каталог для хранения корневых систем| Сделано |
| /var/lib/firecracker/microvm | Каталог для хранения виртуальных машин| Сделано |
| /var/lib/firecracker/metrics | Каталог для хранения метрик виртуальных машин| Не сделано |
| /var/run/firecracker | Каталог для socket-файлов | Сделано | 
| /var/log/firecracker/ | Каталог для логов | Сделано |
| /etc/selinux | Каталог для файлов Selinux| Не сделано |
| /etc/firewalld | Каталог для файлов Firewalld| Не сделано |

Запуск виртуальных машин будет происходить через параметризированную службу firecracker@.service. Рассмотрим пример, если нам нужно запустить виртуальную машину с именем testcentos, то нам нужны будут:


| Тип | Содержание |
|-----|------------|
| Служба systemd  | firecracker@testcentos.service  |
| Файл конфигурации  | /etc/firecracker/testcentos.json  |
| ROOTFS  | /var/lib/firecracker/microvm/testcentos.ext4  |


## Сборка пакета

Предполагаю, что у вас уже настроено рабочее окружение для сборки пакетов. Если нет, то вы можете ознакомится [здесь](https://fedoraproject.org/wiki/Using_Mock_to_test_package_builds), [здесь](https://www.easycoding.org/2017/02/22/sobiraem-rpm-pakety-dlya-fedora-v-mock.html) и [здесь](https://sites.google.com/site/syscookbook/rhel/rhel-rpm-build).
Также предполагаю, что у вас уже есть опыт работы с RHEL и работа с пакетами у вас не вызывает трудностей.

Для сборки пакета нам нужно скачать бинарные файлы с github - [firecracker](https://github.com/firecracker-microvm/firecracker/releases/download/v0.21.1/firecracker-v0.21.1-x86_64), [jailer](https://github.com/firecracker-microvm/firecracker/releases/download/v0.21.1/jailer-v0.21.1-x86_64)

```
wget https://github.com/firecracker-microvm/firecracker/releases/download/v0.21.1/firecracker-v0.21.1-x86_64

mv ./firecracker-v0.21.1-x86_64 ~/rpmbuild/SOURCES/firecracker
chmod a+x ~/rpmbuild/SOURCES/firecracker

wget https://github.com/firecracker-microvm/firecracker/releases/download/v0.21.1/jailer-v0.21.1-x86_64
mv jailer-v0.21.1-x86_64 rpmbuild/SOURCES/jailer
chmod a+x ~/rpmbuild/SOURCES/jailer
```

Создадим параметризированную службу systemd

```
cat<<EOF | tee rpmbuild/SOURCES/firecracker@.service
[Unit]
Description=Firecracker starting microvm %I
After=network.target

[Service]
PrivateTmp=true
Type=simple
PIDFile=/var/run/firecracker/%i.pid
ExecStartPre=-/bin/rm /var/run/firecracker/%I.socket
ExecStart=/usr/sbin/firecracker --api-sock /var/run/firecracker/%I.socket --config-file /etc/firecracker/%I.json

[Install]
WantedBy=multi-user.target
EOF
```

Создадим шаблон spec-файл для сборки пакета

```
rpmdev-newspec rpmbuild/SPECS/firecracker.spec
```

Шаблон Spec-файла выглядит так:

```
Name:           firecracker
Version:
Release:        1%{?dist}
Summary:

License:
URL:
Source0:

BuildRequires:
Requires:

%description


%prep
%setup -q


%build
%configure
make %{?_smp_mflags}


%install
rm -rf $RPM_BUILD_ROOT
%make_install


%files
%doc



%changelog
```

Теперь файл нужно привести к следующему виду:

```
Name:           firecracker
Version:        v0.21.1
Release:        1%{?dist}
Summary:        Open source virtualization technology

License:        Apache License 2.0
URL:            https://github.com/firecracker-microvm/firecracker
Source0:        https://github.com/firecracker-microvm/firecracker/releases/download/v0.21.1/firecracker-v0.21.1-x86_64
Source1:        https://github.com/firecracker-microvm/firecracker/releases/download/v0.21.1/jailer-v0.21.1-x86_64
Source2:        firecracker@.service
BuildArch:      x86_64

BuildRequires:  systemd

Requires(post): systemd systemd-sysv chkconfig
Requires(preun): systemd
Requires(postun): systemd

%description
Firecracker is an open source virtualization technology that is purpose-built for creating and managing secure, multi-tenant container and function-based services that provide serverless operational models. Firecracker runs workloads in lightweight virtual machines, called microVMs, which combine the security and isolation properties provided by hardware virtualization technology with the speed and flexibility of containers.

%build

%install

rm -rf %{buildroot}

mkdir -p %{buildroot}%{_sbindir} \
        %{buildroot}%{_var}/lib/firecracker/{kernels,rootfs,microvm,metrics} \
        %{buildroot}%{_var}/run/firecracker \
        %{buildroot}%{_var}/log/firecracker \
        %{buildroot}%{_sysconfdir}/firecracker \
        %{buildroot}%/usr/share/firecracker/scripts

install -d -m 0755 %{buildroot}/etc/firecracker
install -d -m 0755 %{buildroot}/usr/share/firecracker
install -d -m 0755 %{buildroot}/usr/share/firecracker/scripts
install -d -m 0755 %{buildroot}/var/lib/firecracker
install -d -m 0755 %{buildroot}/var/lib/firecracker/kernels
install -d -m 0755 %{buildroot}/var/lib/firecracker/rootfs
install -d -m 0755 %{buildroot}/var/lib/firecracker/microvm
install -d -m 0755 %{buildroot}/var/lib/firecracker/metrics
install -d -m 0755 %{buildroot}/var/run/firecracker
install -d -m 0755 %{buildroot}/var/log/firecracker

install -m 0755 %{SOURCE0} %{buildroot}/%{_sbindir}/firecracker
install -m 0755 %{SOURCE1} %{buildroot}/%{_sbindir}/jailer

mkdir -p %{buildroot}%{_unitdir}
install -m644 %{SOURCE2} %{buildroot}%{_unitdir}

%clean
rm -rf %{buildroot}

%post
%systemd_post firecracker@.service

%preun
%systemd_preun firecracker@.service

%postun
%systemd_postun_with_restart firecracker@.service

%files
%defattr(-,root,root,-)
%dir /etc/firecracker
%dir /usr/share/firecracker
%dir /usr/share/firecracker/scripts
%dir /var/lib/firecracker
%dir /var/lib/firecracker/kernels
%dir /var/lib/firecracker/rootfs
%dir /var/lib/firecracker/microvm
%dir /var/lib/firecracker/metrics
%dir /var/run/firecracker
%dir /var/log/firecracker
%{_sbindir}/firecracker
%{_sbindir}/jailer
%{_unitdir}/firecracker@.service
%doc



%changelog
* Mon May 18 2020 Nurmukhamed Artykaly <nurmukhamed.artykaly@hdfilm.kz> v0.21.1-1
- Initial spec file
```

Собираем RPM-пакет 

```
spectool -g -R ~/rpmbuild/SPECS/firecracker.spec
rpmbuild -bs ~/rpmbuild/SPECS/firecracker.spec
sudo mock ~/rpmbuild/SRPMS/firecracker-v0.21.1-1.el7.src.rpm
```

Готовый пакет будет здесь

```
ll /var/lib/mock/epel-7-x86_64/result/
total 2800
-rw-rw-r-- 1 root mock    9792 May 18 16:03 build.log
-rw-r--r-- 1 root mock 1850581 May 18 16:03 firecracker-v0.21.1-1.el7.src.rpm
-rw-r--r-- 1 root mock  914196 May 18 16:03 firecracker-v0.21.1-1.el7.x86_64.rpm
-rw-rw-r-- 1 root mock    1568 May 18 16:03 hw_info.log
-rw-rw-r-- 1 root mock   16450 May 18 16:03 installed_pkgs.log
-rw-rw-r-- 1 root mock   56517 May 18 16:03 root.log
-rw-rw-r-- 1 root mock     847 May 18 16:03 state.log
```

Можем установить пакет

```
sudo yum localinstall /var/lib/mock/epel-7-x86_64/result/firecracker-v0.21.1-1.el7.x86_64.rpm

```

Теперь созданный пакет можем поместить в локальный репозиторий, поставить цифровую подпись, отслеживать изменения, своевременно обновлять пакеты на машинах.

## Сборка ядра

Нам понадобится ядро Linux. Варианты:

* Можно скачать уже [готовое ядро](https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md);
* Можно собрать [вручную свое ядро](https://github.com/firecracker-microvm/firecracker/blob/master/docs/rootfs-and-kernel-setup.md).

Разберем второй вариант. 

[По данной ссылке](https://linuxhint.com/compile-linux-kernel-centos7/) подготовим рабочее окружение и загрузим последнею версию ядра.

```
sudo yum install flex flex-devel bison bison-devel ncurses-devel make gcc bc openssl-devel elfutils-libelf-devel rpm-build

wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.6.13.tar.xz
tar xvf linux-5.6.13.tar.xz

cd linux-5.6.13
curl https://raw.githubusercontent.com/firecracker-microvm/firecracker/master/resources/microvm-kernel-x86_64.config -o .config

make menuconfig
```

Ничего не выбираем, просто сохраняем конфиг как .config

```
make vmlinux
```

Скопируем полученный файл в каталог /var/lib/firecracker/kernels/

```
sudo cp ./vmlinux /var/lib/firecracker/kernels/vmlinux-5.6.13
```

Теперь мы можем организовать целый каталог ядер, который может быть использован под различные задачи с различными требованиями.

## Сборка корневой системы

Нам понадобится корневая система. Варианты:

* Можно скачать уже [готовую корневую систему]((https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md));
* Можно собрать [вручную свою корневую систему](http://www.forevergenin.com/posts/linux/bootstrapping-centos-rootfs/).

Разберем второй вариант.

### Сборка корневой системы CentOS

В данной сборке будет минимальная система CentOS, включая **systemd-networkd** и **openssh-server**. Эти пакеты необходимы, чтобы виртуальная машина запускалась с настроенной сетью и серверов openssh для удаленного доступа.

Подготовим рабочее окружение

```
cd
mkdir myrootfs
cat<<EOF | tee chroot-centos7.repo
[centos7-chroot-base]
name=CentOS-7-Base
baseurl=http://mirror.centos.org/centos/7/os/x86_64
gpgcheck=0
[centos7-chroot-epel]
name=Extra Packages for Enterprise Linux 7
baseurl=http://dl.fedoraproject.org/pub/epel/7/x86_64
gpgcheck=0
EOF
```

Установим минимальный набор пакетов

```
sudo yum -y -c chroot-centos7.repo --disablerepo=* --enablerepo=centos7-chroot-base --enablerepo=centos7-chroot-epel --disableplugin=* --installroot=/home/nurmukhamed/myrootfs install \
	bash \
	bash-completion \
	vim-minimal \
	yum \
	iproute \
	iputils \
	rootfiles \
	sudo \
    systemd-networkd \
    openssh-server \
    openssh
```


Подготовка к chroot

```
sudo mount --bind /dev ~/myrootfs/dev
sudo mount --bind /dev/pts ~/myrootfs/dev/pts
sudo mount --bind /sys ~/myrootfs/sys
sudo mount --bind /proc ~/myrootfs/proc
sudo cp /etc/resolv.conf ~/myrootfs/etc/
```

Chroot
```
sudo bash
cd ~/myrootfs
chroot ~/myrootfs

```

Внутри chroot
```
echo "7" > /etc/yum/vars/releasever
echo "x86_64" > /etc/yum/vars/basearch

yum update -y 

yum clean all
rm -rf /boot /var/cache/yum/*

systemd-tmpfiles --create --boot
rm -f /var/run/nologin

echo 'firecracker' > /etc/yum/vars/infra

awk '(NF==0&&!done){print "override_install_langs='$LANG'\ntsflags=nodocs";done=1}{print}' \
    < /etc/yum.conf > /etc/yum.conf.new
mv /etc/yum.conf.new /etc/yum.conf

rm -f /usr/lib/locale/locale-archive

#Setup locale properly
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
/bin/date +%Y%m%d_%H%M > /etc/BUILDTIME

# Create folder for systemd-networkd service
mkdir /etc/systemd/network

:> /etc/machine-id

exit
```

Отключаем разделы
```
sudo rm ~/myrootfs/etc/resolv.conf
sudo umount ~/myrootfs/dev/pts
sudo umount ~/myrootfs/dev
sudo umount ~/myrootfs/sys
sudo umount ~/myrootfs/proc
```

Чистка 
```
sudo rm -rf ~/myrootfs/boot
sudo rm -rf ~/myrootfs/var/cache/yum/*
sudo rm -f ~/myrootfs/tmp/ks-script*
sudo rm -rf ~/myrootfs/var/log/*
sudo rm -rf ~/myrootfs/tmp/*
sudo rm -rf ~/myrootfs/etc/sysconfig/network-scripts/ifcfg-*
```

Произведем упаковку образа

```
sudo -Jcvf /var/lib/firecracker/rootfs/centos7-$(/bin/date +%Y%m%d).tar.xz -C /home/nurmukhamed/myrootfs .
```

Теперь у нас имеется образ ОС CentOS, который мы можем развернуть в любой момент.

### TODO - Сборка корневой системы Debian

### TODO - Сборка корневой системы Ubuntu


## Создание параметризированной службы systemd

На данный момент у нас имеются:

* Пакет firecracker;
* Собранное ядро linux 5.6.13;
* Собранная корневая система ОС CentOS 7.

Теперь мы можем приступить к запуску первой виртуальной машины в firecracker.

Имя виртуальной машины: testcentos

```
sudo systemctl enable firecracker@testcentos.service
```

Наша параметризированная служба теперь будет искать файл /etc/firecracker/testcentos.json.
В этом файле будут описаны параметры виртуальной машины

## Шаблон виртуальной машины

Параметры нашей виртуальной машины:

| Параметр       | Значение                                            | 
|----------------|-----------------------------------------------------|
| CPU            | 2                                                   |
| RAM            | 1024MB                                              |
| Hyper-Thread   | false                                               |
| Kernel Path    | /var/lib/firecracker/kernels/vmlinux-5.6.13         |
| RootFS Image   | /var/lib/firecracker/rootfs/centos7-20200518.tar.xz |
| RootFS Path    | /var/lib/firecracker/microvm/testcentos.ext4        |
| RootFS Size    | 8GB                                                 |
| NIC            | eth0                                                |
| IP-address     | 172.16.0.2                                          |

Для запуска виртуальной машины нам необходимо развернуть образ ОС CentOS.

```
sudo dd if=/dev/zero of=/var/lib/firecracker/microvm/testcentos.ext4 bs=1M count=8192
sudo mkfs.ext4 /var/lib/firecracker/microvm/testcentos.ext4
sudo mkdir /tmp/testcentos
sudo mount -o loop /var/lib/firecracker/microvm/testcentos.ext4 /tmp/testcentos
sudo tar -Jxvf /var/lib/firecracker/rootfs/centos7-20200518.tar.xz -C /tmp/testcentos

```

Нужно сгенерировать пароль пользователя root. Установим пароль как "MySecretPassword".

```
sudo rm /tmp/testcentos/etc/shadow*

password=$(python -c "import random,string,crypt;
randomsalt = ''.join(random.sample(string.ascii_letters,8));
print crypt.crypt('MySecretPassword', '\$6\$%s\$' % randomsalt)")

cat<<EOF| sudo tee /tmp/testcentos/etc/shadow
root:${password}:18353:0:99999:7:::
bin:*:18353:0:99999:7:::
daemon:*:18353:0:99999:7:::
adm:*:18353:0:99999:7:::
lp:*:18353:0:99999:7:::
sync:*:18353:0:99999:7:::
shutdown:*:18353:0:99999:7:::
halt:*:18353:0:99999:7:::
mail:*:18353:0:99999:7:::
operator:*:18353:0:99999:7:::
games:*:18353:0:99999:7:::
ftp:*:18353:0:99999:7:::
nobody:*:18353:0:99999:7:::
systemd-network:!!:18400::::::
dbus:!!:18400::::::
EOF

cat<<EOF| sudo tee /tmp/testcentos/etc/shadow-
root:${password}:18353:0:99999:7:::
bin:*:18353:0:99999:7:::
daemon:*:18353:0:99999:7:::
adm:*:18353:0:99999:7:::
lp:*:18353:0:99999:7:::
sync:*:18353:0:99999:7:::
shutdown:*:18353:0:99999:7:::
halt:*:18353:0:99999:7:::
mail:*:18353:0:99999:7:::
operator:*:18353:0:99999:7:::
games:*:18353:0:99999:7:::
ftp:*:18353:0:99999:7:::
nobody:*:18353:0:99999:7:::
systemd-network:!!:18400::::::
dbus:!!:18400::::::
EOF

sudo chown root:root /tmp/testcentos/etc/shadow*
sudo chmod 0000 /tmp/testcentos/etc/shadow*
```

Настройки сетевой карты 

```
cat<<EOF | sudo tee /tmp/testcentos/etc/systemd/network/20-wired.network
[Match]
Name=eth0

[Network]
Address=172.16.0.2/24
Gateway=172.16.0.1
DNS=8.8.8.8
EOF
```

```
sudo umount /tmp/testcentos
sudo rmdir /tmp/testcentos
```

Образ развернут, теперь нужна [конфигурация виртуальной машины](https://github.com/firecracker-microvm/firecracker/blob/master/tests/framework/vm_config.json). Наша тестовая конфигурация будет выглядет так:

```
macaddress=$(echo 00:60:2F:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10])
cat<<EOF | sudo tee /etc/firecracker/testcentos.json
{
  "boot-source": {
    "kernel_image_path": "/var/lib/firecracker/kernels/vmlinux-5.6.13",
    "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "/var/lib/firecracker/microvm/testcentos.ext4",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "machine-config": {
    "vcpu_count": 2,
    "mem_size_mib": 1024,
    "ht_enabled": false
  },
  "network-interfaces": [ 
      {
      "iface_id": "eth0",
      "guest_mac": "${macaddress}",
      "host_dev_name": "testcentos"
    }
  ],
  "actions": {
      "action_type": "InstanceStart"
  }
}
EOF
```

Также нам понадобится [генератор MAC-адресов](https://superuser.com/questions/218340/how-to-generate-a-valid-random-mac-address-with-bash-shell) для генерации случайных MAC-адресов. В данной статье я не буду проверять на уникальность полученные адреса. **А вы должны!**

Конфигурация сетевой карты будет далее.

## Настройка сети

Более подробно настройка сети для firecracker приведена [здесь](https://github.com/firecracker-microvm/firecracker/blob/master/docs/network-setup.md).

```
sudo ip tuntap add testcentos mode tap
sudo ip addr add 172.16.0.1/24 dev testcentos
sudo ip link set testcentos up
```

## Настройка firewalld

Используйте firewalld, забудьте про iptables править вручную.

```
sudo firewall-cmd --new-zone=testcentos --permanent
sudo firewall-cmd --reload
sudo firewall-cmd --zone=testcentos --change-interface=testcentos
sudo firewall-cmd --zone=testcentos --add-service=ssh
sudo firewall-cmd --zone=public --add-masquerade
```

В данной конфигурации, настройки firewalld будут работать до перегрузки системы. 

## Запуск виртуальной машины

```
sudo systemctl start firecracker@testcentos.service
```

В случае ошибки, можно посмотреть логи системы

```
sudo journalctl -u firecracker@testcentos.service
```

## TODO Автоматизация действий
Теперь у нас появилась возможность для автоматизации наших действий и программно запускать виртуальные машины в firecracker.

Представим, что у нас имеется рабочий CI/CD, например, Gitlab. Тогда мы можем добавить в него еще 3 pipeline:

* Сборка ядер, по мере выхода новых ядер или исправления критических уязвимостей;
* Сборка образов корневых систем;
* Создание виртуальной машины с заданными параметрами.


##  TODO Примеры:
###  TODO CentOS
###  TODO Debian
###  TODO Ubuntu
##   TODO Дальнейшие действия. 
