---
layout: page
title: "Устанавливаем дополнительные модули для NCALayer"
date: 2022-03-05
comments: true
categories: 
- ubuntu
- bash
- qazaq
- linux
- DRY
- python
- python3
- ansible
- ncalayer
- java
- jar
---

**Устанавливаем дополнительные модули для NCALayer**
<!-- more -->

В ноябре 2021 окончательно перешел на Ubuntu. Купил жесткий диск, установил систему, создал пользователя. Все как обычно.

NCALayer работает нормально, но так как информационных систем работающих в экосистеме Электронного Правительства РК много, каждая информационная система использует свой модуль для NCALayer.
В частности в самом начале у меня в Кабинете налогоплательщика не работала поддержка KazToken. После установки необходимого бандла проблема ушла.

# Ручной способ

NCALayer хранит информацию о бандлах в файле ncalayer.der. Это обычный json-файл, который подписан ЭЦП. Но нам не нужно проверять подпись, я так и не понял как это сделать. Нам нужен только JSON.

В консоле набираем следующие команды 
```
sudo apt update
sudo apt install jq -y

cd ~/.config/NCALayer/bundles
tail +66c ../ncalayer.der|jq -r .ncalayer.bundles[].url | xargs -P16 wget -i 
```

Перезапускаем NCALayer, новые бандлы будут установлены и будут работать.

# Ansible способ

Я конечно не уверен в том, что где-то в Казахстане есть организации, где пользователи используют Linux взамен Windows. 
Но давайте предположим, что такая организация есть и используется Ansible для автоматизации рабочих процессов

## Подготовка

```
sudo apt update
sudo apt install python3-pip python3-venv

python3 -m venv ~/python3/ansible
source ~/python3/ansible/bin/activate

pip install pip --upgrade
pip install ansible ansible-lint

mkdir ~/ansible-playbooks

```

## Рабочий процесс

```
source ~/python3/ansible/bin/activate

cd ~/ansible-playbooks
wget https://gist.githubusercontent.com/Nurmukhamed/3c58c10ad69d7277e4169954b484d9ff/raw/bc2033b996316f3f1b7e30eb9db3afceae9e0d16/ncalayer-bundle-install-playbook.yaml
ansible-playbook ncalayer-bundle-install-playbook.yaml
```
