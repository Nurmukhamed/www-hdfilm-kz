---
title: "Backlog Task #2 - Ergodox Keyboard."
date: 2025-12-31T09:00:00+05:00
summary: ""
categories:
- ergodox
- keyboard
- atmel
- teensy
- qmk
- firmware
- printables
- 3d-printer
- kicad
- jlcpcb
---

**Слабоумие и отвага**: Сборка клавиатуры Ergodox в 2025.
<!--more-->

# Intro

В 2012-2015 годы я собрал клавиатуры [Egrodox][1], [GH60][2]. Было интересно, клавиатуры были собраны,
работают до сих пор. Смета подробная [здесь][3], [здесь][4] и [здесь][5].

Но вот захотелось собрать еще несколько клавиатур, чтобы можно было оставить в офисе, дома, взять в дорогу.

# Архаика

Клавиатура Ergodox появилась в 2010-2011 годы, имела ряд спорных решений - порт MiniUSB, плата Teensy 2.0.
4 пиновый разьем TRRS для связи левого и правого блока между собой.

В 2025 году - это уже очень и очень архаичное решение. Проблема достать разьемы MiniUSB, платы Teensy 2.0, разьемы TRRS.

**Внимание** - Я не рекомендую собирать клавиатуру Ergodox в 2025 году и в последующих годах. 
Посмотрите в сторону проектов, которые развились от Ergodox - это Ergodox EZ, ZSA Moonlander. 

# Trigger

И вот летом 2025 я купил 3д-принтер. Снова, только разница между принтерами из 2015 и 2025 годов - просто космос.

Ну значит решил распечатать [корпуса, keycaps][13]. 

С 2015 года у меня остались Teensy 2.0, кабели TRRS. 

Потом подумал - а собрать одну клавиатуру или 5 клавиатур по времени займет приблизительно одно время.

# Электронные компоненты

Запчасти можно купить на [DigiKey][15], [Mouser][16]. В 2015 году я так и покупал, помню попросили заполнить экспортную декларацию, я ее заполнял и получил посылку.

В 2025 году сайт [DigiKey][15] вообще не открывается из Казахстана, а [Mouser][16] можно сделать заказ - а потом попросили заполнить экспортную декларацию, заполнил и получил отказ.

На [ebay][17], [amazon][18], [aliexpress][19] этих запчастей нет.

Единственно, где они есть - это сайт [FalbaTech][9] из Польши. 
Пан понял жизнь, значит не спешит. 
Возможно, еще в 2012-2015 годы закупил на склад все необходимые компоненты и продает их не спеша.

Если вы находитесь в EU, то рекомендую закупить сразу готовый набор на этом сайте.

Сделал заказ, заказ собирали очень медленно, заняло около 3х недель, потом почта около месяца доставляла посылку.

Таким образом я получил все необходимые запчасти для сборки.

# Изготовление платы - JLCPCB

С сайта github загружаем файлы, делаем zip-архив и загружаем на сайте JLCPCB, оплачиваем и через месяц молучаем набор плат. Я заказывал 10 штук.
Качество изготовления на высоте.

# Сборка

Диоды DO-35 на купил в Астане, на принтере распечатал сгибатель. Приготовил диоды, затем за один выходной день запаял их.
И допустил ошибку, просто невнимательность моя.

**Внимание** - У вас есть мультиметр и вы используете для проверки полярности диодов. То левой половине клавиатуры, красный шуп (+) будет слева, на правой половине клавиатуры красный шуп будет справа. Ну и на плате есть куча отметок, чтобы понять как правильно установить диоды. Но я был не внимательным. Не повторяйте моих ошибок.

Пришлось на aliexpress купить диоды SOD-123, выпаять все диоды на правой половине, затем припаять SMD диоды. Ну скажу так паять DO-35 гораздо проще и приятнее.

# QMK Configurator

Спасибо ребятам из проекта [QMK][12], которые сделали замечательный сайт [QMK Configurator][12]. 
Здесь можно сконфигурировать свою раскладку, скомпилировать и записать прошивку в Teensy.
Я использую программу [QMK Toolbox][20].

Ниже оставлю свою раскладку, если вдруг захотите повторить.
  
~~~json
{
  "documentation": "\"This file is a QMK Configurator export. You can import this at <https://config.qmk.fm>. It can also be used directly with QMK's source code.\n\nTo setup your QMK environment check out the tutorial: <https://docs.qmk.fm/#/newbs>\n\nYou can convert this file to a keymap.c using this command: `qmk json2c {keymap}`\n\nYou can compile this keymap using this command: `qmk compile {keymap}`\"\n",
  "notes": "",
  "version": 1,
  "keyboard": "ergodox_ez/base",
  "keymap": "ergodox_ez_base_layout_ergodox_pretty_2025-10-04",
  "layout": "LAYOUT_ergodox_pretty",
  "layers": [
    [
      "KC_EQL",
      "KC_1",
      "KC_2",
      "KC_3",
      "KC_4",
      "KC_5",
      "KC_ESC",
      "KC_PSCR",
      "KC_6",
      "KC_7",
      "KC_8",
      "KC_9",
      "KC_0",
      "KC_MINS",
      "KC_BSLS",
      "KC_Q",
      "KC_W",
      "KC_E",
      "KC_R",
      "KC_T",
      "TO(1)",
      "KC_LBRC",
      "KC_Y",
      "KC_U",
      "KC_I",
      "KC_O",
      "KC_P",
      "KC_RBRC",
      "KC_TAB",
      "KC_A",
      "KC_S",
      "KC_D",
      "KC_F",
      "KC_G",
      "KC_H",
      "KC_J",
      "KC_K",
      "KC_L",
      "KC_SCLN",
      "KC_QUOT",
      "KC_LSFT",
      "KC_Z",
      "KC_X",
      "KC_C",
      "KC_V",
      "KC_B",
      "TO(2)",
      "KC_NO",
      "KC_N",
      "KC_M",
      "KC_COMM",
      "KC_DOT",
      "KC_SLSH",
      "KC_RSFT",
      "KC_LGUI",
      "KC_GRV",
      "KC_BSLS",
      "KC_LEFT",
      "KC_RGHT",
      "KC_LEFT",
      "KC_DOWN",
      "KC_UP",
      "KC_RGHT",
      "KC_RGUI",
      "KC_LCTL",
      "KC_LALT",
      "KC_LALT",
      "KC_RCTL",
      "KC_HOME",
      "KC_PGUP",
      "KC_BSPC",
      "KC_DEL",
      "KC_END",
      "KC_PGDN",
      "KC_ENT",
      "KC_SPC"
    ],
    [
      "KC_F12",
      "KC_F1",
      "KC_F2",
      "KC_F3",
      "KC_F4",
      "KC_F5",
      "KC_TRNS",
      "KC_TRNS",
      "KC_F6",
      "KC_F7",
      "KC_F8",
      "KC_F9",
      "KC_F10",
      "KC_F11",
      "KC_TRNS",
      "KC_EXLM",
      "KC_AT",
      "KC_LCBR",
      "KC_RCBR",
      "KC_PIPE",
      "TO(0)",
      "KC_TRNS",
      "KC_UP",
      "KC_7",
      "KC_8",
      "KC_9",
      "KC_ASTR",
      "KC_F12",
      "KC_TRNS",
      "KC_HASH",
      "KC_DLR",
      "KC_LPRN",
      "KC_RPRN",
      "KC_GRV",
      "KC_DOWN",
      "KC_4",
      "KC_5",
      "KC_6",
      "KC_PLUS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_PERC",
      "KC_CIRC",
      "KC_LBRC",
      "KC_RBRC",
      "KC_TILD",
      "TO(2)",
      "KC_TRNS",
      "KC_AMPR",
      "KC_1",
      "KC_2",
      "KC_3",
      "KC_BSLS",
      "KC_TRNS",
      "KC_NO",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_DOT",
      "KC_0",
      "KC_EQL",
      "KC_TRNS",
      "UG_NEXT",
      "KC_TRNS",
      "UG_TOGG",
      "ANY(RGB_M_P)",
      "KC_TRNS",
      "KC_TRNS",
      "UG_VALD",
      "UG_VALU",
      "KC_TRNS",
      "KC_TRNS",
      "UG_HUED",
      "UG_HUEU"
    ],
    [
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "MS_UP",
      "KC_TRNS",
      "KC_TRNS",
      "TO(1)",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "MS_LEFT",
      "MS_DOWN",
      "MS_RGHT",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_MPLY",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "TO(0)",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_MPRV",
      "KC_MNXT",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "MS_BTN1",
      "MS_BTN2",
      "KC_VOLU",
      "KC_VOLD",
      "KC_MUTE",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_TRNS",
      "KC_WBAK"
    ]
  ],
  "author": ""
}
~~~

# Links 

* [Ergodox][1]
* [GH60][2]
* [GH60 Komar blog][3]
* [Ergodox - смета на одну клавиатуру][4]
* [Общие расходы на сборку клавиатуры ergodox][5]
* [Общие расходы на сборку клавиатуры gh60][6]
* [Ergodox-EZ][7]
* [ZSA Moonlander][8]
* [Falbatech][9]
* [Ergodox Gerbers][10]
* [JlCPCB][11]
* [QMK Configurator][12]
* [Ergodox STLS][13]
* [Hole Component blender][14]
* [DigiKey][15]
* [Mouser][16]
* [Ebay][17]
* [Amazon][18]
* [Aliexpress][19]
* [QMK Toolbox][20]

[1]: <https://www.ergodox.io/>
[2]: <https://github.com/komar007/gh60>
[3]: <http://blog.komar.be/projects/gh60-programmable-keyboard/>
[4]: <https://www.hdfilm.kz/blog/2014/07/10/ergodox-smeta-na-odnu-klaviaturu/>
[5]: <https://www.hdfilm.kz/blog/2014/07/09/ergodox-rashody/>
[6]: <https://www.hdfilm.kz/blog/2015/04/06/gh60-raskhody/>
[7]: <https://ergodox-ez.com/>
[8]: <https://www.zsa.io/moonlander>
[9]: <https://falbatech.click/>
[10]: <https://github.com/Ergodox-io/ErgoDox/tree/master/ErgoDOX%20pcb/gerber>
[11]: <https://jlcpcb.com/>
[12]: <https://config.qmk.fm/#/ergodox_ez/base/LAYOUT_ergodox_pretty>
[13]: <https://www.printables.com/model/113786-ergodox-mechanical-keyboard>
[14]: <https://www.printables.com/model/240213-biegelehre-improved-through-hole-component-lead-be>
[15]: <https://www.digikey.com/>
[16]: <https://www.mouser.com>
[17]: <https://ebay.com>
[18]: <https://amazon.com>
[19]: <https://aliexpress.com>
[20]: <https://qmk.fm/toolbox>
