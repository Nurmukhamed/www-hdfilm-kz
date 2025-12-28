---
title: "Backlog Task #1 - HP Proliant Microserver Gen8."
date: 2025-12-28T09:00:00+05:00
summary: ""
categories:
- hp
- proliant
- microserver
- gen8
- iLO
- noctua
- modding
- upgrade
- rocky linux

---
Актуальность HP Proliant Microserver Gen8 в 2025 году. Да, актуален.
<!--more-->

# Intro
На OLX.kz нашел объявление о продаже HP Proliant Microserver Gen8. Созвонился и купил себе ящик c базовой конфигурацией.
Также узнал, что есть еще и второй такой же ящик, но без памяти и блока питания. В следующем месяце купил второй ящик.
Основная причина покупки - это наличие встроенного модуля iLO4. Можно управлять серверами удаленно, без дополнительных устройств.

# Замена блока питания

Второй сервер был без блока питания, я нашел [подходящий блок][5] на ebay. Заказал, блок приехал и был установлен без проблем в корпус.
 
# Обновление версии iLO4, BIOS

Необходимо убедится, что прошивки iLO4, BIOS обновлены до последних версии. Последняя версия была выпущена в 2020 году. 
В более ранних версиях прошивок есть баг, который приводил к повреждению прошивки, обновляем на последнею версию и баг проходит.
В последних версиях версия iLO с HTML5, что позволяет использовать современные Firefox, Chrome без проблем.

**СОВЕТ** - не меняйте пароль по умолчанию для входа в iLO4, пароль напечатан на бирке приклееной к корпусу сзади.
Прежние хозяева не меняли пароль.
Я просто сделал фото и сохранил пароли в KeePass.

# Замена вентиляторов  120mm и 40mm

Вентиляторы родные со временем начинают шуметь, ощутимо шуметь. Особенно шумный вентилятор в блоке питания.
Если сервер будет стоят где-нибудь в офисе, то лучше заменить их на другие.
Я рекомендую Noctua [40mm][8], [120mm][7].

В [этой статье][6] описано как это сделать, но есть один момент - желтый провод HP нужно замкнуть на землю (черный провод HP).
В противном случае будет выводится ошибка iLO4 Fan error.

# Использую eMMC-TF-SC-Card Module как загрузочный диск

Внутри сервера имеется порт SD-card, USB для флешки. Я решил установить [модуль eMMC][4], который отлично входит в разьем SD.

Операционную систему я установил на eMMC. Очень медленно работает, особенно загрузка. Но после загрузки уже проблем не бывает.
Я использовал [разбиение диска с проекта Packer examples for vsphere][13], как раз влезает в 32 ГБ. Все остальное - данные - я держу в
отдельном lvm-volume.

# Установка карты LSI9211

По умолчанию дисковая корзина подключена к материнской плате, первые два диска будут работать в SATA3, третий и четвертый диски будут работать в SATA2.
Что не очень хорошо. Дополнительный SATA-порт также SATA2, предназначен для CD/DVD-приводов, где-то читал, что с этого порта нельзя загрузится.
Не проверял.

Ситуацию можно улучшить если установить [плату][10] [LSI9211][11]. Плата имеет 8 портов SATA3, SAS. 4 порта будут использоваться для дисковой корзины.
остальные 4 порта можно использовать подключив еще 4 2.5" SSD-диска. Цены на них падают, 4 диска по 2 ТБ не так дорого стоят.

# Разное

# Ссылки

* [Документация HP][1]
* [Easiest way to update hp iLO4][2]
* [Python-HPiLO][3]
* [eMMC to TF SD Card Module][4]
* [FlexATX PSU][5]
* **Статья на испанском языке** [NAS: Upgrade ventilador HP Microserver Gen8][6]
* [Noctua NF-P12 redux 1700+PWM][7]
* [Noctua NF-A4x20][8]
* [How to Replace 1U Flex Power Supply Fan to 40mm Noctua Fan || PC Mod][9]
* [Adding LSI9211 to HP Microserver Gen8][10]
* [Как подружить LSI 9211 и HP Microserver Gen8][11]
* [Everything I know and like about the HPE Microserver Gen8][12]
* [Packer examples for vsphere][13]

[1]: <https://support.hpe.com/hpesc/public/docDisplay?docId=a00048622en_us> "Документация HP"
[2]: <https://www.reddit.com/r/homelab/comments/udbg2c/easiest_way_to_update_hp_ilo4/> "Easiest way to update hp iLO4"
[3]: <https://github.com/seveas/python-hpilo> "Python-HPiLO"
[4]: <https://aliexpress.ru/item/1005009639950482.html?shpMethod=CAINIAO_STANDARD&sku_id=12000049724838674&spm=a2g2w.productlist.search_results.5.188c86442oRY9c> "eMMC to TF SD Card Module"
[5]: <https://www.ebay.com/itm/405809904541> "FlexATX PSU"
[6]: <https://www.maquinasvirtuales.eu/nas-upgrade-ventilador-hp-microserver-gen8/> "nas-upgrade-ventilador-hp-microserver-gen8"
[7]: <https://www.amazon.com/Noctua-redux-1700-high-Performance-Award-Winning-Affordable/dp/B07CG2PGY6?crid=3G9NSGVAB6L3T&dib=eyJ2IjoiMSJ9.2yu38tfLowVKkjlkN4AVmdngG8vGIttpCvgeZymqrLIeDvYagyCt0_4PNyTspKsLsWvgy0pd7oewVrPR4CtBcZETN4AKdcUOGKplsMdHuJrm7MzJV8KmFNcYAs7v7xqDws5Mlp5AQug_1z30Ltkh4cINYETGtTZfN7bqXVc6Sr-_EJRKMSxWML91p1f3VkrmwOb1fjqPM0VXnw-TSfDOUHoJ4gPq06uCmFcNy9UXRhQ.Irbfn4a6eBdbwrutDfKgpqAAdpeLzyp-8jh80FGUfRg&dib_tag=se&keywords=Noctua+NF-P12+redux-1700+PWM&qid=1762964607&sprefix=noctua+nf-p12+redux-1700+pwm%2Caps%2C251&sr=8-1> "Noctua Redux 1700"
[8]: <https://www.amazon.com/Noctua-NF-A4x20-PWM-Premium-Quality-Quiet/dp/B071W93333?crid=2EVYTM480LQIO&dib=eyJ2IjoiMSJ9.VEVsjf1g1NtoYB48GQLtJYSEdOBvQbGpnOnWc5OjnfaQgsfsvNaf6QA-DIIC6SQvyq14fPT8nntLXBaiMgWFyRKJVGRlo5U3plfIaSeZOBB2-xbaZpnPYTzwzbo6EHjiyJo8NHY3-IIi8i9aCtialbNN9w1_j_XafbFdDc_c-pLeshEhW8KYDb8wrLbJ4UTKLCkMGkYi0ZeU_VxEC2jkMuqC3HB7SwNi3nJa1fTeKpE.cPNAeO64Nbl_z3KgmVrOU7c-QI8t22hDKYASFpp68_I&dib_tag=se&keywords=Noctua%2BNF-A4x20&qid=1762964801&sprefix=noctua%2Bnf-a4x20%2Caps%2C302&sr=8-1&th=1> "Noctua A4x20 fan"
[9]: <https://www.youtube.com/watch?v=YhFbd5NMGz4> "How to Replace 1U Flex Power Supply Fan to 40mm Noctua Fan || PC Mod"
[10]: <https://www.jackpearce.co.uk/posts/adding-lsi9211-hp-microserver-gen8> "Adding LSI9211 to HP Microserver Gen8"
[11]: <https://medium.com/@dittohead/%D0%BA%D0%B0%D0%BA-%D0%BF%D0%BE%D0%B4%D1%80%D1%83%D0%B6%D0%B8%D1%82%D1%8C-lsi-9211-%D0%B8-hp-microserver-gen8-b09b6549bb61> "Как подружить LSI 9211 и HP Microserver Gen8"
[12]: <https://dennis.schmalacker.cloud/posts/hp-microserver-gen8-peculiarities/> "Everything I know and like about the HPE Microserver Gen8"
[13]: <https://github.com/vmware/packer-examples-for-vsphere/blob/develop/tests/storage/golden/lvm-kickstart> "Packer examples for vsphere"
