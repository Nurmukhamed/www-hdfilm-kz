---
layout: page
title: Используем spi-flash для восстановления Orange Pi PC
date: 2020-01-16
comments: true
published: true
categories:
- linux
- armbian
- OrangePiPC
- spiflash
- sunxi-fel
- LinuxOrgRu
- U-Boot
---

Инструкция как восстановить Orange Pi PC, если сломался слот SD-карт <!--more-->

## Предыстория
У меня имеется Orange Pi PC (далее - плата), уже пару лет. Мощное железо, 1 ГБ ОЗУ, 1 ГБит/с Ethernet порт. Для домашних задач подходит. В последнее время работала как шлюз для 3д-принтера. Но в какой-то момент, уже в апреле 2019 года, перестал работать слот SD-карт и система перестала грузится.

## Update

* 2022-01-18 - Добавлен новый [репозиторий](https://github.com/Nurmukhamed/OrangePIPC-Boot-From-SPIFLASH) для сборки в Docker. **Настоятельно советую использовать этот репозиторий**;
* 2022-01-18 - Исправлены ошибки;
* Добавлен [пост про сборку u-boot для orange pi zero plus](http://www.hdfilm.kz/blog/2020/01/17/OrangePIZeroPlus-Boot-From-SPIFLASH/).
* 2025-09-09 - Платы давно нет, но вот rpi_spi_board у меня осталось много, если вы находитесь в Астане, то могу отдать сами платы бесплатно, не более 5 плат на руки.

## TODO

* Не работает загрузка по сети.


## Чего я не знал

### Различные режимы загрузки Orange Pi PC
Плата имеет различные режимы загрузки. Основные - загрузка с SD-карты, MMC, SPI-Flash.

### Режим sunxi-fel
Существует специальный режим платы - sunxi-fel. Нужно отключить от платы sd-карту, подключить micro-usb кабель к плате, второй конец к компьютеру, желательно, под Linux. В этом режиме можно управлять платой, в частности, можно записывать образ u-boot на установленную на плате spi-flash и (или) удаленно загрузить образ U-boot в память и загрузить плату.

### Проект с ЛОРа
Летом нашел проект на Linux.Org.Ru с простой платой-переходником, чтобы удобно было припаять spi-flash (sop8) на переходник и затем подключать ее к плате. Автор выложил проект на [github](https://github.com/ktkd/rpi_spi_board), я сделал [fork](https://github.com/Nurmukhamed/rpi_spi_board) и дополнительно добавил файлы в Gerber, чтобы можно было заказать на китайских фабриках.

## Что нам нужно

* Компьютер под управлением [Ubuntu](https://ubuntu.com/);
* ПО [ARM Trusted Firmware](https://github.com/ARM-software/arm-trusted-firmware)
* ПО [U-boot](https://www.denx.de/wiki/U-Boot);
* ПО [Sunxi-fel](https://linux-sunxi.org/FEL);
* [Плата](http://www.orangepi.org/orangepipc/);
* [Плата-переходник с spi-флешкой](https://www.linux.org.ru/forum/talks/15114641?cid=15464327);

## Сборка пакетов.
Необходимо собрать ARM Trusted Firmware. 

Перед сборкой проверим систему:

```
sudo apt update
sudo apt install gcc-arm-linux-gnueabihf bison flex swig
```

Затем нужно собрать U-boot, для Orange Pi PC команды следующие:

```
cd
git clone https://github.com/u-boot/u-boot
cd u-boot
make distclean
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- orangepi_pc_defconfig
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- 
```

Эти файлы нужно изменить, чтобы включить загрузку u-boot через spi-flash

**DTS-файл**
```
--- ./o/u-boot/arch/arm/dts/sun8i-h3-orangepi-pc.dts  2019-12-09 14:16:34.638633856 +0300
+++ ./n/u-boot/arch/arm/dts/sun8i-h3-orangepi-pc.dts  2019-10-09 20:19:42.792490685 +0300
@@ -54,6 +54,7 @@
   aliases {
     ethernet0 = &emac;
     serial0 = &uart0;
+                spi0 = &spi0;
   };
 
   chosen {
@@ -140,6 +141,35 @@
   status = "okay";
 };
 
+&spi0 {
+        status = "okay";
+
+        flash@0 {
+                #address-cells = <1>;
+                #size-cells = <1>;
+                compatible = "mxicy,mx25l1606e", "winbond,w25q128";
+                reg = <0>;
+                spi-max-frequency = <40000000>;
+                partitions {
+                        compatible = "fixed-partitions";
+                        #address-cells = <1>;
+                        #size-cells = <1>;
+
+                        qspi_boot: partition@0 {
+                                label = "Boot and fpga data";
+                                reg = <0x0 0x4000000>;
+                        };
+
+                        qspi_rootfs: partition@4000000 {
+                                label = "Root Filesystem - JFFS2";
+                                reg = <0x4000000 0x4000000>;
+                        };
+                };
+        };
+};
+
+
+
 &hdmi {
   status = "okay";
 };
```

**Config-файл**

```
CONFIG_ARM=y
CONFIG_ARCH_SUNXI=y
CONFIG_NR_DRAM_BANKS=1
CONFIG_SPL=y
CONFIG_MACH_SUN8I_H3=y
CONFIG_DRAM_CLK=624
# CONFIG_SYS_MALLOC_CLEAR_ON_INIT is not set
CONFIG_USE_PREBOOT=y
CONFIG_SPL_I2C_SUPPORT=y
CONFIG_SPL_SPI_SUNXI=y
# CONFIG_SYS_MALLOC_CLEAR_ON_INIT is not set
CONFIG_USE_PREBOOT=y
CONFIG_SYS_SPI_U_BOOT_OFFS=0x8000
# CONFIG_CMD_FLASH is not set
# CONFIG_SPL_DOS_PARTITION is not set
# CONFIG_SPL_EFI_PARTITION is not set
CONFIG_DEFAULT_DEVICE_TREE="sun8i-h3-orangepi-pc"
CONFIG_SUN8I_EMAC=y
CONFIG_SY8106A_POWER=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_OHCI_HCD=y
CONFIG_SYS_USB_EVENT_POLL_VIA_INT_QUEUE=y
```
После сборки у вас должен появится файл **u-boot-sunxi-with-spl.bin**. Этот файл необходимо залить на флешку.

## Загрузка образа на spi-флешку

Подключите плату к компьютеру с установленным ПО sunxi-fel

**Проверим, что плата подключена и определяется программой sunxi-fel**
```
sudo sunxi-fel sid
```

**Проверим, что плата видит spi-flash**
```
sudo sunxi-fel spiflash-info
```

**Записываем образ на флешку**

```
sudo sunxi-fel -p spiflash-write 0 u-boot-sunxi-with-spl.bin
```

**Проверяем записанный образ**

```
sudo sunxi-fel -p spiflash-read 0 `stat -c %s u-boot-sunxi-with-spl.bin` spi-flash-read-data.bin
cmp -b u-boot-sunxi-with-spl.bin spi-flash-read-data.bin
```

## Загрузка системы с USB-флешки.

* Необходимо записать образ Armbian на флешку;
* отключаем питание на плате;
* подключаем usb-флешку к плате;
* включаем плату и ждем когда плата запросит адрес по DHCP-протоколу.

В случае ошибок, необходимо подключиться к консоле, 3 пина между HDMI-портом и разьемом питания.
От разъема питания к HDMI - Ground, RX, TX. Подключить через USB-TTL-serial (pl2102 и подобные)

```
sudo screen /dev/ttyUSBX 115200
```

## Итог

```
Using username "nurmukhamed".
nurmukhamed@orangepipc's password:
  ___  ____  _   ____   ____
 / _ \|  _ \(_) |  _ \ / ___|
| | | | |_) | | | |_) | |
| |_| |  __/| | |  __/| |___
 \___/|_|   |_| |_|    \____|

Welcome to Armbian buster with Linux 5.4.8-sunxi

System load:   0.17 0.10 0.09   Up time:       1 day
Memory usage:  8 % of 998MB     IP:            192.168.1.231 192.168.1.115
CPU temp:      56°C
Usage of /:    14% of 7.2G

[ General system configuration (beta): armbian-config ]

Last login: Wed Jan 15 06:39:01 2020 from 192.168.1.201

nurmukhamed@orangepipc:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            432M     0  432M   0% /dev
tmpfs           100M  5.5M   95M   6% /run
/dev/sda1       7.2G  988M  6.1G  14% /
tmpfs           500M     0  500M   0% /dev/shm
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
tmpfs           500M     0  500M   0% /sys/fs/cgroup
tmpfs           500M  4.0K  500M   1% /tmp
/dev/zram0       49M  2.2M   43M   5% /var/log
tmpfs           100M     0  100M   0% /run/user/1000
nurmukhamed@orangepipc:~$
```

# Дополнение создал небольшой 
