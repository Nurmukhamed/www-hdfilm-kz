---
title: "Goatcounter - счетчик посещений"
date: 2025-11-01T12:44:55+05:00
summary: ""
categories:
- arp242
- goatcounter
- docker
- docker-compose
- postgresql

---
Прикрутил к веб-сайту hdfilm.kz счетчик посещений goatcounter.
<!--more-->

# Предыстория

Данный сайт, блог я веду в стиле "автор писатель, автор не читатель".

В связи с этим в целом меня не волновало, кто меня читает, зачем читает и из какой страны меня читают.

Но в последние полгода я получил пару писем, с просьбой обновить пару старых постов. 

Что и было сделано.

Также мне на почту постоянно, регулярно пишет один SEO из Украины и предлагает помочь, но мне вообще лень.

Вообщем идею в голову положили. 

Что хорошо бы иметь хоть какое-либо понимание, что на самом деле происходит с сайтом.

# Goatcounter

[Goatcounter](https://github.com/arp242/goatcounter/tree/main) - это простое приложение на Golang-е написанный пользователем github arp242. 

Автор перечисляет преимущества своего решения:

* Privacy-aware;
* Lightweight and fast;
* Identify unique visits;
* Easy;
* Accessibility;
* Open source;
* Own your data.

# Docker compose

Автор предоставил очень подробную информацию как развернуть свой инстанс.

Я выбрал решение на базе Docker Compose. 

Docker Compose состоит из двух контейнеров - postgresql, goatcounter.

~~~yaml
services:
  db:
    image: postgres:16 # Specifies the PostgreSQL image version
    restart: always # Ensures the container restarts automatically
    shm_size: 128mb
    environment:
      POSTGRES_USER: "goatcounter" # Sets the PostgreSQL username
      POSTGRES_PASSWORD: "goatcounter" # Sets the PostgreSQL password
      POSTGRES_DB: "goatcounter" # Sets the default database name
    volumes:
      - /opt/goatcounter/db:/var/lib/postgresql/data # Persists data using a named volume
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U goatcounter -d goatcounter"]
      interval: 5s
      timeout: 5s
      retries: 5
    deploy:
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
  goatcounter:
    image: arp242/goarcounter
    build:
      context: /opt/goatcounter/goatcounter
    container_name: goatcounter
    depends_on:
      db:
        condition: service_healthy
    environment:
      GOATCOUNTER_DB: 'postgresql+postgresql://goatcounter:goatcounter@db:5432/goatcounter?sslmode=disable'
      TZ: "Asia/Aqtobe" # Your current timezone
    volumes:
      - /opt/goatcounter/data:/home/goatcounter/goatcounter-data
    ports:
      - 127.0.0.1:8080:8080
    restart: unless-stopped # This makes sure that the application restarts when it crashes
~~~

# Hugo + Goatcounter

Можно поискать в интернете, для себя я сделал [следующее изменение в своем блоге](https://github.com/Nurmukhamed/www-hdfilm-kz/commit/6f1dfd31e92dfa743da092dbd9b312525de7f097).

# Insights

Оказывается, самой интересной статьей на сайте  является статья "[Используем spi-flash для восстановления Orange Pi PC](https://hdfilm.kz/blog/2020/01/16/orangepipc-boot-from-spiflash/)".
