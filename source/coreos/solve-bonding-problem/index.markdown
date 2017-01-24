---
layout: page
title: "CoreOS: Решение проблем с bond-интерфейсом при загрузке"
date: 2015-02-25 15:17
comments: true
sharing: true
footer: true
previous: "coreos/list-of-used-links"
---

**Проблема**

Имеется сервер с 2 сетевыми картами, подключенный к коммутатору, сетевые карты обьедены в один bond0 интерфейс.
Если в ручную настроить:

<pre><code>
    ip link set dev enp6s0f0 down
    ip link set dev enp6s0f1 down

    modprobe bonding miimon=100

    ip link set dev enp6s0f0 master bond0
    ip link set dev enp6s0f1 master bond0

    ip ad add 192.168.1.200/24 dev bond0
</code></pre>

то сеть работает. Но если перегрузить сервер, то bond0 интерфейс создается, но enp6s0f0 и enp6s0f1 не будут добавлены
к bond0. соответственно сеть не работает.

Начал изучать интернет, оказалось проблема в следующем:

*   coreos поднимает интерфейс enp6s0f0, enp6s0f1
*   интерфейс bond0 не может включить enp6s0f0, enp6s0f1, так как эти интерфейсы уже подняты.


**Решение**

если в cloud-config.yaml включить данный код:

<pre><code>
coreos:
    units:
        - name: runcmd.service
          command: start
          content: |
            [Unit]
            Description=Solve bond0 problem

            [Service]
            Type=oneshot
            ExecStart=/bin/sh -c "ip link set dev enp6s0f0 down; ip link set dev enp6s0f1 down; systemctl restart systemd-networkd.service; systemctl restart fleet.service"
</code></pre>

то после перезагрузки сеть работает.


**Links**

[Ссылка 1](https://github.com/coreos/bugs/issues/36)
[Ссылка 2](http://stackoverflow.com/questions/27072198/execute-commands-in-a-coreos-cloud-config-e-g-to-add-swap)
