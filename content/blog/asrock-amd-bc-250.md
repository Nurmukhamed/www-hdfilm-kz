---
title: "Смета по сборке Steam OS на базе Asrock AMD BC-250"
date: 2026-02-17T12:44:55+05:00
summary: ""
categories:
- asrock
- amd
- bc-250
- steam
- steam os
- bazzite
- printables
- ebay
- aliexpress
- 

---
Смета для сборки Steam OS на базе [Asrock AMD BC-250](https://www.ixbt.com/news/2026/02/10/ps5-190-amd-bc-250-steamos.html).
<!--more-->

В январе 2026 года [Youtube](https://www.youtube.com/watch?v=-spFYYnsQS4) показал мне ролик о волшебной платы Asrock AMD BC-250.
Sony заказывает у AMD процессор/графический процессор PlayStation 5, самое лучшее уходит в Sony, 
а остальные подождут. И в 2021 году Asrock на базе отбраковки выпустила блейд Asrock AMD BC-250.
В шасси помещается 12 штук и использовались в майнинге.

Ну майнинг на графических картах уже в прошлом, платы стали никому не нужны, продавались по бросовым ценам.
В январе 2025 года на ebay можно было купить за 25 - 30 долларов США.

В течение 2025 года умельцы научились запускать на этих платах Fedora 40, затем Steam OS, получили игровой компьютер.

Ну вообщем я решился - лучше сделать и сидеть на дошираке, чем быть сытым и сожалеть об утраченной возможности.

# Смета

Цены актуальные для января 2026 года и в тенге.


| # | Наименование          | Стоимость | Примечание |
|---|-----------------------|-----------|------------|
| 1 | Asrock AMD BC-250     | 99802     | Ebay       |
| 2 | FSP500-30AS           | 22332     | Ebay       |
| 3 | Wifi6 AX900           | 13128     | Aliexpress |
| 4 | Кнопка и разьем       | 11199     | Postal.KZ  |
| 5 | Доставка              | 25215     | Postal.KZ  |
| 6 | Bambu Lab ABS         | 21000     | Kaspi      |
| 7 | 512GB Apacer AS2280P4 | 74990     | Shop.KZ    |

# Links

* [Asrock AMD BC-250](https://www.ebay.com/itm/147107397364?var=445601139158)
* [FSP500-30AS](https://www.ebay.com/itm/389522369783)
* [Molex (24 Circuits)](https://www.amazon.com/Molex-Circuits-Receptacle-Terminals18-24-Mini-Fit/dp/B079DB1QZF?pd_rd_w=rJMuV&content-id=amzn1)
* [Molex, 10 Circuit Connector](https://www.amazon.com/dp/B074LYZKMS?ref=cm_sw_r_cso_cp_apin_dp_0ATSTXCA1YGKBABX4GK9&social_share=cm_sw_r_cso_cp_apin_dp_0ATSTXCA1YGKBABX4GK9&badgeInsights=insights)
* [UGREEN 4K DisplayPort to HDMI Adapter](https://www.amazon.com/dp/B0FCLXJHTX?ref=ppx_pop_mob_ap_share&th=1)
* [16mm Latching Push Button Switch](https://www.amazon.com/dp/B07RLP1TVB?ref=cm_sw_r_cso_cp_mwn_dp_K6N9HRASDPPYF1ME1QVK&social_share=cm_sw_r_cso_cp_mwn_dp_K6N9HRASDPPYF1ME1QVK&titleSource=true&badgeInsights=bestseller-insights&th=1)
* [Wifi6 AX900](https://aliexpress.ru/item/1005008818739752.html?spm=a2g2w.orderdetail.0.0.ad574aa6Oo7cJn&sku_id=12000046802349241)
* [Copper Threaded Nut Inserts](https://aliexpress.ru/item/1005005920120561.html?spm=a2g2w.orderdetail.0.0.5f2c4aa6LBzf10&sku_id=12000034855956852)
* [512GB Apacer AS2280P4](https://shop.kz/offer/ssd-nakopitel-512-gb-apacer-as2280p4-m-2-pcie-3-0/)
* [Assembling Mini-Fit JR with IWIS SN-28B Crimper](https://www.youtube.com/watch?v=a1WHy_oDHnM)

# 3d-Printer Case

Я нашел [следующий проект корпуса](https://www.printables.com/model/1499974-nexgen3d-diy-steam-machine-powered-by-bazzite). 

Напечатал корпус на пластике ABS. Печатал два раза. 
В первый раз напечатал в 100% масштаб, затем в 101% масштабе.
Думаю, нужно было печатать в 100.05% масштабе.
Тогда скорее всего все сойдется.

# Сборка

**ВАЖНО** Необходимо провести деструктивные действие над радиатором. Делайте это на свежую голову и обязательно отсоедините радиатор от платы.

* Раскрываем ребра радиатора;
* Печатаем держатель вентилятора;
* С помощью кримпера обжимаем провода кнопки и подключаем в разьем папа Molex;
* Подключаем блок питания к кнопке и к плате;
* Собираем корпус и закрепляем c помощью болтов;
* Подключаем и проверяем.

# Установка bazzite

Установка системы простая, скачиваем ISO образ, записываем на флешку.
Загружаемся с флешки и проводим процедуру установки ОС.

Затем быстро [по инструкции](https://elektricm.github.io/amd-bc250-docs/linux/bazzite/) меняем настройки ОС.

Это важно, так как плата работает в режиме максимальной производительности, 
настройки устанавливают более оптимальный режим работы.

У меня появились следующие проблемы

* Компьютер и монитор подключены через кабель DisplayPort, который шел в комплекте с монитором, нет звука.
* Wifi6 не заработал в компьютере, в итоге я использовал другой wifi адаптер.

С первым рекомендуют купить адаптер DisplayPort -> HDMI, может звук появится.

Со вторым - ну пишут что в ядре 6.17 данный тип wifi6 был добавлен, но скорее всего в Bazzite он не попал.


