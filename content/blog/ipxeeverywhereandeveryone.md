---
layout: page
title: "ipxe для всех и даром."
date: 2015-07-24
comments: true
categories: 
- ipxe
---

Короткая статья раскажет почему стоит отказаться от pxe и начать использовать ipxe.
<!-- more -->

**Недостатки pxe**

*   Протокол pxe очень древний. Технология развивается с  [1984](https://en.wikipedia.org/wiki/Preboot_Execution_Environment) года.
*   В качестве транспорта используется протокол [tftp](https://en.wikipedia.org/wiki/Trivial_File_Transfer_Protocol). Древний, небезопасный, медленный протокол.
*   Без [dhcp](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) не будет работать.
*   Нет возможности использовать другие протоколы http, ftp, https, fcoe, iscsi



Но pxe продолжают использовать. В основном "Так исторически сложилось". и в интернете полно материала, как настроить pxe.

Я считаю, что в данное время использование pxe не оправдано.

Нужно использовать его приемника - ipxe.

** Приемущества ipxe**

*   Протокол разрабатывается с 2010 года. 
*   Поддерживает IPv4, IPv6
*   Поддерживает в качестве транспорта различные протоколы - tftp, ftp, http, https
*   Имеет поддержку платформы виртуализации vmware, что позволяет настраивать ipxe из vmx файла виртуальной машины
*   [В онлайн режиме](http://rom-o-matic.eu) сгенерировать нужные вам образы
*   Может работать и без протокола dhcp
*   Есть своя система скриптов, позволяет кастомизировать образы по своему усмотрению.

ipxe уже используется в qemu, vmware, встроен в различные сетевые карты.

Все что остается, прочитать документацию, настроить ipxe, перестать волноваться и начать жить.




