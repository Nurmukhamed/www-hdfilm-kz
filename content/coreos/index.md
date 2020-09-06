---
layout: page
title: Кластер CoreOS для освоения Docker
date: '2015-02-13 14:58'
comments: true
sharing: true
footer: true
published: true
---

<!--more-->
**Цели**

Данная статья - это конспект, всего что нужно было сделать, чтобы поднять первый тестовый кластер CoreOS.
Основной целью развертывания CoreOS-кластера является:

* изучение новой технологии Docker
* изучение работы кластера CoreOS
* запуск тестовой площадки для проверки решения

****Update****: Данная статья была написано давно и частично устарела. В ближайшее время будет обновлены разделы.

**Содержание**

*   [Вводная часть.](/coreos-intro/)
*   [Описание железа, виртуальных машин, топология сети](/coreos-hardware-description/)
*   ****Устарело**** [Установка кластера CoreOS на ETCD](/coreos-setup-coreos-cluster/)
*   ****Обновление**** [Установка кластера CoreOS на ETCD2](/coreos-setup-coreos-cluster-etcd2/)
*   [Установка Private Repository](/coreos-setup-private-repository/)
*   [Установка Developers](/coreos-setup-developers-vm/)
*   [Работа с контейнерами, создание базового образа](/coreos-docker-base-tools/)
*   [Создание контейнеров для тестовой площадки](/coreos-create-docker-images-for-test/)
*   [Настройка сервисов в кластере CoreOS](/coreos-setting-services-in-coreos/)
*   [Запуск служб, тестирование работы](/coreos-start-services-testing/)
*   [Список использованной литературы](/coreos-list-of-used-links/)
*   [Решение проблемы при загрузке, если используется bond интерфейс](/coreos-solve-bonding-problem/)

**Обновление**
* [Обновление раздела CoreOS, использование ETCD2 взамен ETCD](/blog/2017/03/13/coreos-pages-update/)
* [COREOS - загрузка по сети](/blog/2017/03/28/coreos-ipxe-server-working-configurations/)