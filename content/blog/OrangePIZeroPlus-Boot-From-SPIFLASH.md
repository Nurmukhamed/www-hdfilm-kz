---
layout: page
title: Используем spi-flash для загрузки с usb-storage на Orange Pi Zero Plus
date: 2020-01-17
comments: true
published: true
categories:
- linux
- armbian
- OrangePiZeroPlus
- spiflash
- sunxi-fel
- LinuxOrgRu
- U-Boot
---

Собираем U-boot для загрузки с usb-storage на Orange Pi Zero Plus <!--more-->

## Предыстория
Это продолжение [прошлого поста](http://www.hdfilm.kz/blog/2020/01/16/OrangePIPC-Boot-From-SPIFLASH/). Решил, что нужно это сделать и забыть.

## TODO

* Не работает загрузка по сети;

## Что нам нужно

* Компьютер под управлением [Ubuntu](https://ubuntu.com/);
* ПО [ARM Trusted Firmware](https://github.com/ARM-software/arm-trusted-firmware)
* ПО [U-boot](https://www.denx.de/wiki/U-Boot);
* ПО [Sunxi-fel](https://linux-sunxi.org/FEL);
* ПО [Flashrom](https://flashrom.org/Flashrom) - **Дополнительно**;
* [Плата](http://www.orangepi.org/OrangePiZeroPlus/);
* [Плата-переходник с spi-флешкой](https://www.linux.org.ru/forum/talks/15114641?cid=15464327);

## Сборка пакетов.
Необходимо собрать ARM Trusted Firmware. Я как-то быстро его собрал, что сейчас не могу вспомнить как это делается. Главное, нам нужен файл **BL31**.


В исходный код U-boot были внесены следующие изменения:

**DTS-файл**
```
nurmukhamed@build:~/u-boot$ git diff arch/arm/dts/sun50i-h5-orangepi-zero-plus.dts
diff --git a/arch/arm/dts/sun50i-h5-orangepi-zero-plus.dts b/arch/arm/dts/sun50i-h5-orangepi-zero-plus.dts
index 1238de25a9..c9b9af5865 100644
--- a/arch/arm/dts/sun50i-h5-orangepi-zero-plus.dts
+++ b/arch/arm/dts/sun50i-h5-orangepi-zero-plus.dts
@@ -27,6 +27,7 @@
                ethernet0 = &emac;
                ethernet1 = &rtl8189ftv;
                serial0 = &uart0;
+               spi0 = &spi0;
        };

        chosen {
@@ -105,17 +106,38 @@
        };
 };

-&spi0  {
+&spi0 {
        status = "okay";
-
-       flash@0 {
+       spi-flash@0 {
                #address-cells = <1>;
-               #size-cells = <1>;
-               compatible = "mxicy,mx25l1606e", "winbond,w25q128";
-               reg = <0>;
-               spi-max-frequency = <40000000>;
+               #size-cells = <0>;
+               compatible = "jedec,spi-nor";
+               reg = <0>; /* Chip select 0 */
+               spi-max-frequency = <3000000>;
+               status = "okay";
+
+               partitions {
+                       compatible = "fixed-partitions";
+                       #address-cells = <1>;
+                       #size-cells = <1>;
+
+                       partition@0 {
+                               label = "uboot";
+                               reg = <0x0 0x100000>;
+                       };
+
+                       partition@100000 {
+                               label = "env";
+                               reg = <0x100000 0x100000>;
+                       };
+
+                       partition@200000 {
+                               label = "data";
+                               reg = <0x200000 0x600000>;
+                       };
+               };
        };
-};
+};

 &ohci0 {
        status = "okay";
```

**Config-файл**
```
nurmukhamed@build:~/u-boot$ git diff configs/orangepi_zero_plus_defconfig
diff --git a/configs/orangepi_zero_plus_defconfig b/configs/orangepi_zero_plus_defconfig
index 22ffbdf2e8..66dc7a6e26 100644
--- a/configs/orangepi_zero_plus_defconfig
+++ b/configs/orangepi_zero_plus_defconfig
@@ -8,6 +8,10 @@ CONFIG_DRAM_ZQ=3881977
 # CONFIG_DRAM_ODT_EN is not set
 # CONFIG_SYS_MALLOC_CLEAR_ON_INIT is not set
 CONFIG_USE_PREBOOT=y
+#CONFIG_SPL_I2C_SUPPORT=y
+CONFIG_SPL_SPI_SUNXI=y
+CONFIG_SPL_SPI_FLASH_SUPPORT=y
+CONFIG_SYS_SPI_U_BOOT_OFFS=0x8000
 # CONFIG_SPL_DOS_PARTITION is not set
 # CONFIG_SPL_EFI_PARTITION is not set
 CONFIG_DEFAULT_DEVICE_TREE="sun50i-h5-orangepi-zero-plus"
```

Эти файлы нужно изменить, чтобы включить загрузку u-boot через spi-flash

Cобраем U-boot:

```
cd
git clone https://github.com/u-boot/u-boot
cd u-boot

export ARCH=aarch64
export CROSS_COMPILE=aarch64-linux-gnu-
export BL31=../arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin

make distclean
make orangepi_zero_plus_defconfig
make  
```

После сборки у вас должен появится файл **u-boot-sunxi-with-spl.bin**. Этот файл необходимо залить на флешку.

## Загрузка образа на spi-флешку через sunxi-fel

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
## Загрузка образа на spi-флешку через flashrom

Плата приходит с распаянной флешкой, то можно использовать утилиту flashrom для заливки образа из самой платы.

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

В данный момент удалось перенести систему на usb-флешку. 
