---
title: "Настройка часов точного времени DS3231 на Debian 12 для платы Le Potato AML-S905X-CC"
date: 2025-10-28T12:44:55+05:00
summary: ""
categories:
- raspberry pi
- pi
- le potato
- s905x
- debian
- rtc
- ds3231
- i2c
- yaml
- ansible

---
Настройка часов точного времени DS3231 на Debian 12 для платы Le Potato AML-S905X-C.
<!--more-->

# Предыстория

Для одного своего хобби-проекта купил себе 5 штук модулей DS3231-module-for-pi. Дома был еще LePotato, решил туда добавить.

Оказалось, что настройка под armbian и debian сильно отличается. Что стало поводом сделать конспект и сохранить на будущее.

# Commands

Необходимо зайти в систему

## Remove Fake HWClock.

~~~bash
sudo systemctl disable fake-hwclock.service
sudo apt remove -y fake-hwclock

sudo systemctl reboot
~~~

## Add ltdo i2c.
~~~bash
/usr/bin/ldto enable i2c-ao
/usr/bin/ldto enable i2c-ao-ds3231
/usr/bin/ldto merge

i2cdetect -y 1

hwclock --show
~~~

Теперь данные времени должны браться с DS3231. 

Если мы перезагрузимся, то все настройки слетят.

Сделаем отдельный systemd service, который будет при старте все настраивать.

~~~bash
cat<<EOF | sudo tee /etc/systemd/system/ds3231-setup.service
[Unit]
Description=Setup DS3231 realtime clock on system.
Documentation=https://www.hdfilm.kz
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ds3231-setup.sh
EOF

cat<<EOF | sudo tee /usr/local/bin/ds3231-setup.sh
#!/bin/bash
#
/usr/bin/ldto enable i2c-ao
/usr/bin/ldto enable i2c-ao-ds3231
/usr/bin/ldto merge

i2cdetect -y 1

hwclock --show
EOF

sudo chmod a+x /usr/local/bin/ds3231-setup.sh
sudo systemctl daemon-reload
sudo systemctl enable ds3231-setup.service
~~~

# Ansible playbook

Решил добавить ansible playbook, так как все равно все делаю в ansible уже последние пару лет.

Необходимо создать следующие файлы.

* ansible.cfg
* inventory
* ds3231-setup-playbook.yaml
* ds3231-setup.service.j2
* ds3231-setup.sh.j2

## ansible.cfg

~~~
[defaults]
inventory = inventory
~~~

## inventory

~~~
[podman]
192.168.1.3

[podman:vars]
ansible_user=support
ansible_port=22
~~~

## ds3231-setup.service.j2

~~~
[Unit]
Description=Setup DS3231 realtime clock on system.
Documentation=https://www.hdfilm.kz
After=network-online.target
Wants=udev.target

[Install]
WantedBy=multi-user.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ds3231-setup.sh
~~~

## ds3231-setup.sh.j2

~~~
#!/bin/bash
#
/usr/bin/ldto enable i2c-ao
/usr/bin/ldto enable i2c-ao-ds3231
/usr/bin/ldto merge

i2cdetect -y 1

hwclock --show
~~~

## ds3231-setup-playbook.yaml

~~~yaml
---
- name: Install and setup ds3231 RTC module.
  hosts: all
  become: true

  handlers:
    - name: Daemon-reload.
      ansible.builtin.systemd:
        daemon_reload: true

    - name: Enable service.
      ansible.builtin.systemd:
        enabled: true
        name: ds3231-setup.service

    - name: Start service.
      ansible.builtin.systemd:
        name: ds3231-setup.service
        state: started

  tasks:
    - name: Ensure that fake-hwclock is disabled and absent.
      ansible.builtin.systemd:
        name: fake-hwclock.service
        enabled: false
        state: absent

    - name: Enable I2C.
      block:
        - name: Enable I2C 1/3.
          ansible.builtin.command:
            cmd: /usr/bin/ldto enable i2c-ao
          register: _rc
          failed_when: _rc.rc != 0

        - name: Enable I2C 2/3.
          ansible.builtin.command:
            cmd: /usr/bin/ldto enable i2c-ao-ds3231
          register: _rc
          failed_when: _rc.rc != 0

        - name: Enable I2C 3/3.
          ansible.builtin.command:
            cmd: /usr/bin/ldto merge
          register: _rc
          failed_when: _rc.rc != 0

    - name: Detect I2C bus 1.
      ansible.builtin.command:
        cmd: i2cdetect -y 1
      register: _rc
      failed_when: _rc.rc != 0

    - name: Show Hardware Clock Data.
      block:
        - name: Show Hardware Clock Data 1/2.
          ansible.builtin.command:
            cmd: hwclock --show
          register: _rc
          failed_when: _rc.rc != 0

        - name: Show Hardware Clock Data 2/2.
          ansible.builtin.debug:
            msg: "{{ _rc.stdout }}"

    - name: Create systemd ds3231-setup service file.
      ansible.builtin.template:
        src: ./ds3231-setup.service.j2
        dest: /etc/systemd/system/ds3231-setup.service
        owner: root
        group: root
        mode: 0644
      notify:
      - Daemon-reload.
      - Enable service.
      - Start service.

    - name: Create systemd ds3231-setup script file.
      ansible.builtin.template:
        src: ./ds3231-setup.sh.j2
        dest: /usr/local/bin/ds3231-setup.sh
        owner: root
        group: root
        mode: 0755
      notify:
      - Daemon-reload.
      - Enable service.
      - Start service.

~~~

Запускаем ansible playbook - в режиме DRY-RUN, смотрим, что все хорошо.
Если не хорошо, то делаем исправления в ansible playbook.

~~~bash
ansible-playbook -C -K ds3231-setup-playbook.yaml
~~~

Затем уже запускаем и смотрим что получилось

~~~bash
ansible-playbook -K ds3231-setup-playbook.yaml
~~~
