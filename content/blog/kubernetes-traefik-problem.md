---
layout: page
title: Проблемы при настройке Kubernetes с Traefik
date: 2017-04-11
comments: true
published: true
categories:
- coreos
- kubernetes
- traefik
- problem
---

Пытаюсь поднять traefik на кластере kubernetes. <!--more-->

В данное время есть рабочий кластер kubernetes на coreos. научился запускать pod, прописывать service, осталось настроить port-forward через ingress. по инструкции с сайта https://traefik.io провожу настройку. вижу проблему - traefik не может подключится с k8s_service_ip. Буду дальше разбираться почему это происходит.
