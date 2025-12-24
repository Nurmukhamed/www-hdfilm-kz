---
title: "Frigate - Go2RTC - Обновление версии"
date: 2025-12-24T12:44:55+05:00
summary: ""
categories:
- frigate
- go2rtc
- nvr
- docker
- Dockerfile
- docker-compose
- wget
- telegram

---
Небольшая статья о том, как обновить go2rtc в контейнере frigate.
<!--more-->

Ребята с [телеграм-канала FrigateNVR](https://t.me/FrigateNVR/99314) подали отличную идею как обновить go2rtc до последней версии.

# Входные данные

* Версия frigate - [0.16.3](https://github.com/blakeblackshear/frigate/releases/tag/v0.16.3);
* Версия go2rtc - [v1.9.13](https://github.com/AlexxIT/go2rtc/releases/tag/v1.9.13);
* Каталог Dockerfile frigate - /opt/docker/frigate;
* Каталог docker-compose - /opt/docker/main.

# Модификация docker образа frigate

В каталоге /opt/docker/frigate создадим файл Dockerfile. 

~~~bash
FROM debian:12 AS download

WORKDIR /tmp

RUN apt-get -y -qq update &&\
    apt-get -y -qq install wget &&\
    wget -q https://github.com/AlexxIT/go2rtc/releases/download/v1.9.13/go2rtc_linux_amd64 &&\
    mv go2rtc_linux_amd64 go2rtc &&\
    chmod a+x go2rtc

FROM ghcr.io/blakeblackshear/frigate:0.16.3 AS frigate

COPY --from=download /tmp/go2rtc /usr/local/go2rtc/bin/go2rtc
~~~

# Модификация docker-compose для сборки docker образа frigate

~~~yaml
services:
  frigate:
    build:
      context: /opt/docker/frigate
#    image: ghcr.io/blakeblackshear/frigate:0.16.3
    container_name: frigate
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /opt/frigate/config:/config
      - /opt/frigate/db:/db
      - /opt/frigate/storage:/media/frigate
      - type: tmpfs # Optional: 1GB of memory, reduces SSD/SD Card wear
        target: /tmp/cache
        tmpfs:
          size: 1000000000
    ports:
      - '192.168.1.2:8554:8554' # RTSP feeds
      - '192.168.1.2:8555:8555/tcp' # WebRTC over tcp
      - '192.168.1.2:8555:8555/udp' # WebRTC over udp
#      - '192.168.1.2:5000:5000'    # Use for initial admin password setup.
      - '192.168.1.2:8971:8971'
    restart: unless-stopped
    devices:
      - /dev/apex_0:/dev/apex_0 # Passes a PCIe Coral, follow driver instructions here https://coral.ai/docs/m2/get-started/#2a-on-linux
      - /dev/apex_1:/dev/apex_1 # Passes a PCIe Coral, follow driver instructions here https://coral.ai/docs/m2/get-started/#2a-on-linux
      - /dev/dri/renderD128:/dev/dri/renderD128
    privileged: true # this may not be necessary for all setups
    shm_size: "1024mb" # update for your cameras based on calculation above
~~~

# Запуск 

~~~bash
sudo docker compose down -v frigate
sudo docker compose up -d frigate
sudo docker compose exec -it frigate go2rtc --version
~~~
