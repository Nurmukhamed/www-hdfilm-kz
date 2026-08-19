---
title: "Настраиваем сетевую загрузку talos"
date: 2026-08-18T12:44:55+05:00
summary: ""
categories:
- netboot
- ipxe
- bios
- uefi
- Talos
- kubernetes
---

Дополнение к статье [Настраиваем сетевую загрузку с помощью mikrotik, ipxe, bios, uefi][1].

<!--more-->

Решил добавить примеры сетевой загрузки для [talos][3]. 

# Intro

Недавно купил себе материнскую плату [D1581Q3A][2]. 
На мой взгляд самая подходящая материнская плата для развертывания тестовых кластеров [Kubernetes][4] в домашних условиях.
16 ядер, 64 ГБ памяти, наверное, позволят запустить кластер на одном узле.

# Фабрика образов

Talos предоставляет отдельный [сервис для сборки и генерации образов][5].

Я использую этот сервис, чтобы получить Talos с нужными мне драйверами (realtek, coral), с нужными программами (iscsi-tools, util-linux-tools).

Вот пример моего образа:

~~~yaml
  customization:
    extraKernelArgs:
        - talos.platform=metal
        - slab_nomerge
        - pti=on
        - init_on_alloc=1/0
        - init_on_free=0/1
    systemExtensions:
        officialExtensions:
            - siderolabs/gasket-driver
            - siderolabs/iscsi-tools
            - siderolabs/realtek-firmware
            - siderolabs/util-linux-tools
~~~

После успешной сборки образа, нужно скачать файлы [kernel-amd64][6], [initramfs-amd64.xz][7], положить в /var/www/html/Talos/1.13.8.

Рекомендую для каждой версии создавать отдельный каталог, места они занимают не много. В случае чего, можно удалить и старые версии и файлы.

# menu.ipxe

menu.ipxe - это файл в котором мы настраиваем сетевую загрузку.

**SKIPPED** - это пропущенные части, весь файл целиком можно посмотреть [здесь][1].

~~~
#!ipxe

menu
  item --gap -- -------------------------- RockyLinux 8 Installation ----------------------
SKIPPED
  item --gap -- -------------------------- Talos --------------------------
  item talos_netboot Netboot Talos (HTTP)
  item talos_netboot_controlplane Netboot Talos ControlPlane Node (HTTP)
  item talos_netboot_worker Netboot Talos Worker Node (HTTP)
SKIPPED

:talos_netboot
  set osroot Talos/1.13.8
  kernel http://${serverip}/${osroot}/kernel-amd64 \
         console=ttyS0 \
         console=tty0 \
         talos.platform=metal \
         slab_nomerge \
         pti=on \
         init_on_alloc=1/0 \
         init_on_free=0/1
  initrd http://${serverip}/${osroot}/initramfs-amd64.xz
  boot

:talos_netboot_controlplane
  set osroot Talos/1.13.8
  set talosconfig Talos/configs
  kernel http://${serverip}/${osroot}/kernel-amd64 \
         console=ttyS0 \
         console=tty0 \
         talos.platform=metal \
         talos.config=http://${serverip}/${talosconfig}/worker.yaml \
         slab_nomerge \
         pti=on \
         init_on_alloc=1/0 \
         init_on_free=0/1
  initrd http://${serverip}/${osroot}/initramfs-amd64.xz
  boot

:talos_netboot_worker
  set osroot Talos/1.13.8
  set talosconfig Talos/configs
  kernel http://${serverip}/${osroot}/kernel-amd64 \
         console=ttyS0 \
         console=tty0 \
         talos.platform=metal \
         talos.config=http://${serverip}/${talosconfig}/worker.yaml \
         slab_nomerge \
         pti=on \
         init_on_alloc=1/0 \
         init_on_free=0/1
  initrd http://${serverip}/${osroot}/initramfs-amd64.xz
  boot

~~~

[1]: https://hdfilm.kz/blog/2025/10/21/ipxe-strikes-back-in-2025/
[2]: https://aliexpress.ru/item/1005010496675349.html?spm=a2g2w.orderdetail.0.0.4f2f4aa6c0qmT1&sku_id=12000052593201023
[3]: https://talos.dev
[4]: https://kubernetes.io/
[5]: https://factory.talos.dev
[6]: https://factory.talos.dev/image/2cf9d9da53c4f50b1e456eca21f2f74238581240dbf6d53c378c1bb010774bc7/v1.13.8/kernel-amd64
[7]: https://factory.talos.dev/image/2cf9d9da53c4f50b1e456eca21f2f74238581240dbf6d53c378c1bb010774bc7/v1.13.8/initramfs-amd64.xz
