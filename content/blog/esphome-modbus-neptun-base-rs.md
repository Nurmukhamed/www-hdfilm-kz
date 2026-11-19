---
title: "Связать между собой Neptun Base RS и HomeAssistant"
date: 2026-11-19T02:44:55+05:00
summary: ""
categories:
- neptun
- neptun base
- HomeAssistant
- hass
- esphome
- modbus
- rs485
- ttl
- uart
- gemini
- google
- ai

---
Небольшая статья о том, как связать между собой Neptun Base RS и HomeAssistant.
<!--more-->

# Intro

[Neptun][1] - это семейство систем защиты от протечками. 
В данный момент, мне известно о трех поколениях данных систем - [Neptun Base][2], [Neptun Smart Plus Tuya][3], [Neptun Alisa][4].

[Neptun Base](https://neptunsale.ru/products/neptun-base) - это простое решение, которое состоит из трех? компонентов - управляющей платы, датчиков протечки, электрических шаровых кранов. Работает дешево и сердито. [Шаровые краны питаются от напряжения в 230 Вольт переменного тока][7]. 

Существует также [улучшенная ревизия с модулем ModBus][2]. Отличие от первой версии на крышке есть надпись "RS". И модуль ModBus. Но я не могу найти именно эту модель на сайте, если вы знаете, то напишите мне на почту, пожалуйста.

Для данной модели существует [документация][5], [карта для ModBus][6]. 
Мне кажется, что вторую ревизию выпустили, чтобы была возможность провести улучшение в существующих системах защиты от протечки, просто поменяв одну плату. Думаю, многим установкам данной системы более 10 - 15 лет. И там шаровые краны на 230 Вольт переменного тока. 

В данный момент все новые решения от Neptun используют шаровые краны на 12 Вольт постоянного тока.

# History

В 2024 году я делал ремонты в своих квартирах, в первой поставил систему Neptun Base, а во второй квартире уже была установлена Neptun Smart Plus Tuya. 

В 2026 году я узнал про вторую ревизию платы, купил ее, но потом передумал ставить, а купил [Neptun Smart Plus Tuya][3] и [шаровые краны на 12 Вольт постоянного тока][7].
Вызвал сантехника и в течение часа поменяли все. В SmartThings добавил новый модуль и через телефон могу видеть состояние системы в двух квартирах.

Но на руках осталось 1 модуль Neptun Base, 1 модуль [Neptun Base RS][2], 1 [шаровый кран на 230 Вольт переменного тока][7].

Я решил, что рано или поздно этим модулям найдется применение.

# Components

Для связи Neptun Base RS с HomeAssistant я купил следующие компоненты - [TTL Turn To RS485 Module Hardware Automatic Flow Control Module Serial UART Level Mutual Conversion Power Supply Module 3.3V 5V][8], [ESP32-C3 Development Board ESP32 SuperMini ][9].

Ну в качестве прошивки буду использовать [EspHome][10], отлично прошивает платы на базе ESP32, поддерживает протокол [ModBus][11]. 

# EspHome Yaml File

Данный файл был написан совместно с [Google Gemini][12]. Я в Google поиске задавал вопрос, затем продолжал диалог с ИИ, добавляя вывод консоли в поисковый запрос, ИИ думал и выдавал еще ответы, и так пока не получил готовый файл, который делает то, что мне нужно.

Что делает EspHome:

* Подключается к Wifi сети, данные берутся из файла secrets.yaml;
* Поднимает UART на пинах GPIO6, GPIO7. Здесь будьте внимательнее, на вашей плате распиновка может быть совсем другой;
* Не использует пины GPIO20, GPIO21, так как они используются для logging;
* Поднимает ModBus соединение поверх UART;
* Подключается к ModBus контроллеру по адресу 1;
* Определяет sensors, binary_sensors, switches. Данные берутся из [документации][6];
* Логика кнопки - Switch - neptun_siren - если она включена, то в случае аварии будет пищать сирена, если не включена, то система будет молчать.
* Логика кнопки - Switch - neptun_valve - если нет тревоги, то позволяет закрывать/открывать краны. если есть тревога, то открыть кран не получится.


~~~Yaml
esphome:
  name: neptunmodbus
  friendly_name: neptunmodbus 

logger:
  level: DEBUG

api:
  encryption:
    key: !secret api_encryption_key

esp32:
  board: esp32-c3-devkitm-1
  variant: ESP32C3
  framework:
    type: arduino

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password
  output_power: 11dB
  fast_connect: false

uart:
  id: mod_uart
  tx_pin: GPIO6
  rx_pin: GPIO7
  baud_rate: 9600
  parity: NONE
  stop_bits: 1

modbus:
  id: modbus_bus
  uart_id: mod_uart
  send_wait_time: 1500ms

modbus_controller:
  - id: neptun_base
    address: 1
    modbus_id: modbus_bus
    update_interval: 10s
    command_throttle: 1500ms

binary_sensor:
  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Протечка"
    address: 11
    register_type: holding
    bitmask: 0x0001  # Бит 0: 0 - нет, 1 - протечка
    device_class: moisture

  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Краны закрыты"
    address: 11
    register_type: holding
    bitmask: 0x0002  # Бит 1: 0 - открыты, 1 - закрыты
    device_class: lock

  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Сервисное обслуживание кранов"
    address: 11
    register_type: holding
    bitmask: 0x0004  # Бит 2: 0 - не активно, 1 - выполняется
    device_class: running

# 2. ПЕРЕКЛЮЧАТЕЛИ УПРАВЛЕНИЯ (Слово управления, регистр 10 / 0x0A, Таблица 3)
switch:
  - platform: template
    id: neptun_siren
    name: "Neptun Звук сирены"
    icon: "mdi:volume-high"
    turn_on_action:
      - lambda: |-
          uint16_t val = (id(neptun_valve).state ? 0x0002 : 0x0000) | 0x0001;
          auto cmd = esphome::modbus_controller::ModbusCommandItem::create_write_multiple_command(
              id(neptun_base), 10, 1, {val});
          id(neptun_base)->queue_command(cmd);
          id(neptun_siren).publish_state(true);
    turn_off_action:
      - lambda: |-
          uint16_t val = (id(neptun_valve).state ? 0x0002 : 0x0000);
          auto cmd = esphome::modbus_controller::ModbusCommandItem::create_write_multiple_command(
              id(neptun_base), 10, 1, {val});
          id(neptun_base)->queue_command(cmd);
          id(neptun_siren).publish_state(false);

  - platform: template
    id: neptun_valve
    name: "Neptun Краны (Открыть)"
    icon: "mdi:valve"
    turn_on_action:
      - lambda: |-
          uint16_t val = (id(neptun_siren).state ? 0x0001 : 0x0000) | 0x0002;
          auto cmd = esphome::modbus_controller::ModbusCommandItem::create_write_multiple_command(
              id(neptun_base), 10, 1, {val});
          id(neptun_base)->queue_command(cmd);
          id(neptun_valve).publish_state(true);
    turn_off_action:
      - lambda: |-
          uint16_t val = (id(neptun_siren).state ? 0x0001 : 0x0000);
          auto cmd = esphome::modbus_controller::ModbusCommandItem::create_write_multiple_command(
              id(neptun_base), 10, 1, {val});
          id(neptun_base)->queue_command(cmd);
          id(neptun_valve).publish_state(false);

sensor:
  - platform: modbus_controller
    modbus_controller_id: neptun_base
    id: neptun_control_word
    address: 10
    register_type: holding
    value_type: U_WORD
    internal: true
    on_value:
      then:
        - lambda: |-
            uint16_t val = (uint16_t)x;
            id(neptun_siren).publish_state(val & 0x0001);
            id(neptun_valve).publish_state(val & 0x0002);

  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Тип устройства"
    address: 0
    register_type: holding
    value_type: U_WORD
    entity_category: diagnostic

  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Версия ПО"
    address: 4
    register_type: holding
    value_type: U_WORD
    entity_category: diagnostic

  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Время подачи питания на краны"
    address: 8
    register_type: holding
    value_type: U_WORD
    unit_of_measurement: "мин"
    entity_category: diagnostic

  - platform: modbus_controller
    modbus_controller_id: neptun_base
    name: "Neptun Период обслуживания кранов"
    address: 9
    register_type: holding
    value_type: U_WORD
    unit_of_measurement: "дн"
    entity_category: diagnostic
~~~

# Images

Быстро "собрал на коленке" все компоненты, чтобы проверить прошивку и как это работает.

{{< imgcap src="/images/20261119-neptun-modbus-esphome-001.png" caption="image001" >}}

Вывод из HomeAssistant

{{< imgcap src="/images/20261119-neptun-modbus-esphome-002.png" caption="image002" >}}

# Links

[1]: https://teploluxe.ru/about/brands/neptun/
[2]: https://teploluxe.ru/catalog/zashchita-ot-protechek-vody/moduli-upravleniya/product/modul_upravleniya_neptun_base/
[3]: https://teploluxe.ru/catalog/zashchita-ot-protechek-vody/moduli-upravleniya/product/modul-upravleniya-neptun-smart-plus-tuya/
[4]: https://teploluxe.ru/catalog/zashchita-ot-protechek-vody/moduli-upravleniya/product/umnyy-modul-upravleniya-dlya-sistem-zashchity-ot-protechki-vody-neptun-umnyy-dom-s-alisoy/
[5]: https://silaobogreva.ru/content/Neptun%20Base/p3g3qorwuynb8cmezgi6scgs2zb253m2.pdf
[6]: https://s.siteapi.org/1b05f7bbad9a56b/docs/sbhmtui8neskc0ooskows8cwwkwow8
[7]: https://teploluxe.ru/catalog/zashchita-ot-protechek-vody/sharovye-krany-s-elektroprivodom/product/neptun-profi-220v-sharovoy-kran-s-elektroprivodom/
[8]: https://aliexpress.ru/item/1005001621746811.html?spm=a2g2w.orderdetail.0.0.39834aa6itX8jj&sku_id=12000016846569467
[9]: https://aliexpress.ru/item/1005007951875758.html?sku_id=12000043002591085&spm=a2g2w.productlist.search_results.0.44a3c71aPdTq6X
[10]: https://esphome.io/
[11]: https://ru.wikipedia.org/wiki/Modbus
[12]: https://gemini.google.com/
