---
title: "Запуск transmission в podman на Rocky Linux 8"
date: 2025-10-20T12:44:55+05:00
summary: ""
categories:
- python
- transmission
- torrent
- podman
- rockylinux
- selinux
- systemd

---
Запуск transmission в podman на Rocky Linux 8.
<!--more-->

# Предыстория

В сентябре 2025 года купил себе два HP Proliant Microserver Gen8. Один в рабочем состояние, другой не рабочий (нет блока питания и памяти).

Железо уже старое, поддерживает только Legacy BIOS, нет UEFI загрузок, прошивка старая. Но удалось обновить версию BIOS 2019 года и iLO 2020 года.
Ну загрузку смог решить только через сетевую загрузку ipxe, напишу попозже об этом в другой статье.

# Данные

* OS Rocky Linux 8.10;
* CPU Intel(R) Celeron(R) CPU G1610T @ 2.30GHz
* RAM 8GB
* HDD 1TB, 10TB;
* Podman взамен Docker;
* Transmission как клиент для Torrent.

# Podman

Podman используется по умолчанию, взамен Docker. Рекомендую прочитать книгу [Podman in Action](https://www.piter.com/collection/all/product/podman-v-deystvii).

Клиента торрент transmission будем запускать под пользователем transmission.

Создадим свой systemd unit transmission.service для запуска торрент клиента.

# Create user and group

~~~bash
sudo groupadd -g 1001 transmission
sudo useradd -g 1001 -u 1001 -m -d /home/transmission -c "Transmission client" -s /bin/bash transmission
~~~

# Install podman

~~~bash
sudo dnf -y update
sudo dnf -y install podman
~~~

# Create folders and set selinux labels

~~~bash
sudo mkdir /opt/transmission
sudo mkdir -p /data/transmission/complete /data/transmission/incomplete
sudo chown transmission:transmission -R /opt/transmission /data/transmission
sudo semanage fcontext -a -t container_file_t "/data/transmission(/.*)?"
sudo semanage fcontext -a -t container_file_t "/opt/transmission(/.*)?"
sudo restorecon -Rv /data/transmission/
sudo restorecon -Rv /opt/transmission/
~~~

# Systemd unit

~~~bash
cat<<EOF | sudo tee /etc/systemd/system/transmission.service
[Unit]
Description=Podman container-transmission.service
Documentation=man:podman-generate-systemd(1)
Wants=network-online.target
After=network-online.target
RequiresMountsFor=/tmp/containers-user-1001/containers

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
Group=transmission
User=transmission
ExecStartPre=-/usr/bin/podman system migrate 
ExecStartPre=-/usr/bin/podman stop transmission
ExecStartPre=-/usr/bin/podman rm transmission
ExecStart=/usr/bin/podman \
  run -d \
  --name transmission \
  -e TZ=Asia/Aqtobe \
  -p 9091:9091 \
  -p 51413:51413 \
  -p 51413:51413/udp \
  -v /opt/transmission/config:/config:z \
  -v /data/transmission:/downloads:z  \
  docker.io/linuxserver/transmission
ExecStop=/usr/bin/podman stop  \
  -t 10 transmission
ExecStopPost=/usr/bin/podman stop  \
  -t 10 transmission
Type=forking

[Install]
WantedBy=default.target

sudo systemctl enable --now transmission.service
sudo systemctl status transmission.service
EOF
~~~

# Еще раз меняем владельцев файлов transmission.

**ОЧЕНЬ ВАЖНО:** чтобы лучше понять этот раздел, рекомендую прочитать книгу [Podman in Action](https://www.piter.com/collection/all/product/podman-v-deystvii), глава "Непривилегированные (rootless) контейнеры", страница 150. Ну по крайней мере в моей книге на русском языке так.

Docker образ linuxserver/transmission - это сложный контейнер, тем что оно запускает сперва supervise,
 а supervise запускает под пользователем abc (910) transmission.

podman запускает весь контейнер под пользователем transmission, внутри контейнера создается отдельное пространство имен, под которым уже запускаются процессы в контейнере.

По этой причине, когда вы добавите новую торрент-раздачу в клиенте, то появится ошибка "Permission denied", даже не смотря на то, что основной процесс контейнера запущен под пользователем transmission. 

Начать нужно смотреть на содержимое файлов /etc/subgid, /etc/subuid. Например на моем сервере вывод будет следующим

~~~bash
[transmission@storage ~]$ cat /etc/subgid
support:100000:65536
transmission:165536:65536
[transmission@storage ~]$ cat /etc/subuid
support:100000:65536
transmission:165536:65536
~~~

То есть все процессы запущенные в контейнере transmission будут начинаться с GID, UID 165536 до (165536 + 65536). При этом root пользователь будет иметь GID, UID 165535. Ну я так думаю.

Посмотрим, под каким пользователем запущен процесс transmission в контейнере transmission.

~~~bash
[support@storage ~]$ sudo su - transmission
[sudo] password for support:
[transmission@storage ~]$ podman exec -it transmission ps -ef
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 14:57 ?        00:00:00 /package/admin/s6/command/s6-svscan -d4 -- /run/service
root          16       1  0 14:57 ?        00:00:00 s6-supervise s6-linux-init-shutdownd
root          22      16  0 14:57 ?        00:00:00 /package/admin/s6-linux-init/command/s6-linux-init-shutdownd -d3 -c /run/s6/basedir -g 3000 -C -B
root          35       1  0 14:57 ?        00:00:00 s6-supervise s6rc-oneshot-runner
root          36       1  0 14:57 ?        00:00:00 s6-supervise s6rc-fdholder
root          37       1  0 14:57 ?        00:00:00 s6-supervise svc-cron
root          38       1  0 14:57 ?        00:00:00 s6-supervise svc-transmission
root          46      35  0 14:57 ?        00:00:00 /package/admin/s6/command/s6-ipcserverd -1 -- /package/admin/s6/command/s6-ipcserver-access -v0 -E
root         163      38  0 14:57 ?        00:00:00 bash ./run svc-transmission
root         164      37  0 14:57 ?        00:00:00 busybox crond -f -S -l 5
abc          172     163  0 14:57 ?        00:00:05 /usr/bin/transmission-daemon -g /config -f
root         217       0 99 15:24 pts/0    00:00:00 ps -ef
[transmission@storage ~]$ podman exec -it transmission grep abc /etc/passwd
abc:x:911:911::/config:/bin/false
[transmission@storage ~]$ exit
[transmission@storage ~]$
~~~

Процесс transmission запущен под GID, UID 911.

Посмотрим какие GID, UID получили файлы, созданные transmission в каталоге /opt/transmission. Это служебный каталог.

~~~bash
[transmission@storage ~]$ ls -alZ /opt/transmission/
total 0
drwxr-xr-x. 3 transmission transmission unconfined_u:object_r:container_file_t:s0  20 Oct 16 12:23 .
drwxr-xr-x. 3 root         root         system_u:object_r:usr_t:s0                 26 Oct 16 12:22 ..
drwxr-xr-x. 5       166446       166446 system_u:object_r:container_file_t:s0     153 Oct 20 15:21 config
~~~

Теперь нужно еще раз изменить владельца на каталоги /data/transmission/complete, /data/transmission/incomplete.
~~~bash
sudo chown 166446:166446 -R /data/transmission/complete /data/transmission/incomplete
~~~

**ЕЩЕ РАЗ** На вашем компьютере или сервере могут быть совершенно другие числа получится. Поэтому лучше начинать смотреть на /etc/subgid, /etc/subuid.

# firewalld

Добавим порты в firewalld, перезапустим firewalld.

~~~bash
sudo firewall-cmd --permanent --add-port=9091/tcp
sudo firewall-cmd --permanent --add-port=51413/tcp
sudo firewall-cmd --permanent --add-port=51413/udp
sudo firewall-cmd --reload
~~~
