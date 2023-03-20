---
layout: page
title: "Устанавливаем Windows 7 в 2023 году."
date: 2023-03-20
comments: true
categories: 
- windows
- ipxe
- wimboot
- winpe
- python
- updates
- chocolatley
- powershell

---

**Устанавливаем Windows 7 в 2023 году.**
<!-- more -->

# Введение

С 2021 года основной операционной системой у меня является Ubuntu Linux. Рабочий ноутбук сейчас Apple MacBook Air M2. 
Но у меня еще есть старенький ноутбук Lenovo Thinkpad X201i, который был куплен мной в 2010 году (за сумашедшие тогда 320.000 тенге).
К сожалению, я не знаю как убить этот ноутбук. На этом ноутбуке успешно была установлена Ubuntu Linux, i3. Медленно, но стабильно работало. 
Для ускорения я также собрал ядро с минимальным количеством модулей.

В данный момент мое хобби - сканировать домашний архив документов и фотографии, который достался мне от дедушки с бабушкой. Я пробывал сканировать под
Ubuntu, но картинка более тусклая чем под Windows + IrfanView. Поэтому было решено установить Windows 7 (родная для ноутбука операционная система).

Расскажу о проблемах. Работы я проводил в ночь с субботы на воскресенье, допустил пару ошибок, которые обеспечили работу до 3х часов ночи (или утра).

# Кабель Micky  Mouse

Есть домашний сервер на Ubuntu, который еще работает как медиа-центр. Подключен к розетке через кабель Микимаус. На блоке питания ноутбука тоже Микимаус.
И такой кабель у меня только один. 

Когда нужен был ноутбук, отключал домашний сервер. Когда нужен был домашний сервер, отключал ноутбук.  

# Загрузочный носитель информации

Я купил новую флешку на 32 ГБ, нашел статью как [форматировать флешку правильным образом][1]. Затем нужно было найти [образ Windows 7][2].
Так как у меня ноутбук шел с предустановленной версией Windows, то скачивание образа Windows не является нарушением лицензионного соглашения.

* Примонтировал флешку;
* примонтировал iso образ;
* скопировал данные на флешку;
* сделал флешку загрузочной;
* воткнул в ноутбук;
* загрузился в БИОС, не вижу флешку.

# Решаем вопрос с загрузкой

На ноутбуке установлена Ubuntu, поэтому я решил отредактировать [Grub2][3], чтобы можно было загрузить [iso образ ipxe][4].

Созрел следующий план действии:

* Загружаемся в ipxe;
* Быстро нажимаем CTRL+B;
* Набираем команду dhcp;
* На MacBook монтируем iso образ Windows. Дисковая утилита -> Файл -> Открыть образ диска -> Выбираем образ;
* На MacBook создадим новую папку wimboot, скопируем туда следующие файлы:
* * bcd;
* * boot.sdi;
* * boot.wim;
* * bootmgr;
* * fonts/boot.ttf;
* * fonts/segmono.ttf;
* * fonts/segoe_slboot.ttf;
* * fonts/segoen_slboot.ttf;
* * fonts/wgl4_boot.ttf;
* * [wimboot][5];
* На MacBook нужно поднять веб-сервер, самый простой способ это сделать - python3
* * python3 -m http.server в каталоге wimboot
* Создаем скрипт ipxe - boot.ipxe;
```
#!ipxe
  
set base http://MACBOOKIP:8000
kernel ${base}/wimboot
initrd ${base}/bootmgr bootmgr
initrd ${base}/install.bat install.bat
initrd ${base}/winpeshl.ini winpeshl.ini
initrd ${base}/bcd BCD
initrd ${base}/boot.sdi boot.sdi
initrd ${base}/boot.wim boot.wim
initrd ${base}/fonts/segmono_boot.ttf segmono_boot.ttf
initrd ${base}/fonts/segoe_slboot.ttf segoe_slboot.ttf
initrd ${base}/fonts/segoen_slboot.ttf segoen_slboot.ttf
initrd ${base}/fonts/wgl4_boot.ttf wgl4_boot.ttf
boot
```
* Переписываем/переопределяем [скрипты winpe][6]
* * install.bat;
```
wpeinit
start /wait cmd.exe
```
* * winpeshl.ini;
```
[LaunchApps]
"install.bat"
```
* На ноутбуке набираем
* * chain http://MACBOOKIP:8000/boot.ipxe
* Загружается windows PE;
* Через утилиту diskpart определяем какие есть диски, партишены и волюмы;
* Переходим к установочным файлам, набираем setup.exe;
* Устанавливаем Windows 7.

# Проблема №1

Флешка была отформатирована в exfat. Windows 7 не понимает данную файловую систему.

**Решение** - с официального сайта Microsoft скачивает официальный образ Windows 11. Оттуда скачиваем нужные файлы.
Загружаемся еще раз на ноутбуке, в этот раз загрузится 11 версия WinPE, которая умеет работать с exfat волюмами.

# Проблема №2

Windows 11 нужен bootmgr, fonts.

**Решение** - скачиваем эти файлы с официального образа.

# Проблема №3

WSUS Offline не поддерживает Windows 7. 

**Решение** - После некоторого времени поиска в Google был найден форум, на котором был дан [рецепт как обновить Windows Updates для Windows 7][7].
Чтобы не потерять, я скопирую сюда рецепт

```
To get up to date, you'll then need to download these and INSTALL THEM IN THIS ORDER :
KB2533552 : https://www.catalog.update.microsoft.com/Search.aspx?q=kb2533552
Download the one without "Embedded" in text. It updates the "Windows Update" within Windows 7 to accept the big Service Pack 1 package (without it, it will take literally hours for the Service Pack 1 to install)
KB976932 :  https://www.catalog.update.microsoft.com/Search.aspx?q=KB976932
You'll want the one in the middle, titled "Windows 7 Service Pack 1 for x64-based Systems (KB976932)", 912.4 MB
From there, you have the unofficial service Pack 2 called "Convenience Rollup Update for Windows 7 SP1 and Windows 2008" : https://support.microsoft.com/en-us/topic/convenience-rollup-update-for-windows-7-sp1-and-windows-server-2008-r2-sp1-da9b2435-2a1c-e7fa-43f5-6bfb34767d65
In order to be able to install it, you need to first install:
KB30200369 : April 2015 servicing stack update for Windows 7 and Windows Server 2008 R2  : https://www.catalog.update.microsoft.com/Search.aspx?q=KB3020369
Second link is for 64 bit version - it's another update for "Windows update" to allow installing lots of updates in one shot
Then the actual cumulative update :
KB3125574 : Update for Windows 7 for x64-based Systems (KB3125574)  : https://www.catalog.update.microsoft.com/search.aspx?q=kb3125574
Last one in the list is for 64 bit, 477 MB.
Then you should be able to just get the latest cumulative security updates which is a package of security updates from this "SP2" until the end
Again, you need to install some small updates to be able to install the big update
KB4490628  2019-03 Servicing Stack Update for Windows 7 for x64-based Systems (KB4490628)  : https://www.catalog.update.microsoft.com/Search.aspx?q=KB4490628
KB4474419 : a hashing/encryption library update , library is used by windows update (last entry is windows 7 64 bit) :  https://www.catalog.update.microsoft.com/Search.aspx?q=KB4474419
KB4536952 : another " windows update" update : https://www.catalog.update.microsoft.com/Search.aspx?q=KB4536952
and now you can actually get the last package of updates
kb4534310 : Security rollup  : https://www.catalog.update.microsoft.com/Search.aspx?q=KB4534310
Second link is Windows 7 64 bit
```

# Проблема №4

Драйвера

**Решение** - Нам поможет [Snappy Driver Installer][8]. 

* Необходимо скачать торрент;
* загрузить полный комплект файлов;
* перекинуть файлы ноутбук - может занять очень много времени (около 37 ГБ данных);
* запустить Snappy Driver Installer;
* подождать, перезагрузится;
* еще раз запустить Snappy Driver Installer до тех пор пока все драйвера не будут установлены.

# Проблема №5

Не получается установить [Chocolatley][9].

**Решение** 

* Нужно установить DotNet 4.7;
* обновить Powershell до 3 версии;
* установить Chocolatley по [официальной инструкции по установке][10];
* обновить powershell до 5 версии через choco install powershell.

# Links


[1]: https://wiki.networksecuritytoolkit.org/nstwiki/index.php?title=HowTo_Create_A_GPT_Disk_With_EFI_System_And_exFAT_Partitions_Using_Parted
[2]: https://windows64.net/99-windows-7-professional-x64-originalnyy-obraz-sp1.html
[3]: https://wiki.syslinux.org/wiki/index.php?title=MEMDISK
[4]: https://boot.ipxe.org/ipxe.iso
[5]: https://ipxe.org/wimboot
[6]: https://ipxe.org/howto/winpe
[7]: https://www.eevblog.com/forum/general-computing/updating-windows-7/msg4239211/#msg4239211
[8]: https://sdi-tool.org/?lang=ru
[9]: https://chocolatey.org/
[10]: https://chocolatey.org/install