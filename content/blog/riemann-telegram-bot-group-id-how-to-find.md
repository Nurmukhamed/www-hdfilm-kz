---
layout: page
title: "Настройка Telegram Bot для системы мониторинга Riemann"
date: 2021-02-27
comments: true
categories:
- linux
- monitoring
- riemann
- telegram
- bot
- bash
- curl
---

# Предыстория

История о моих ошибках при настройке Telegram Bot для системы мониторинга Riemann. <!-- more --> 
Поставили задачу создать новую группу в телеграме и подключить в эту группу. Вроде все сделал по мануалам, только оповещения приходят только мне. В группу не приходят.

# Инструкции

* [Инструкция по работе с BotFather ботом](https://medium.com/@bbsystemscorporation/%D0%B8%D0%BD%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%86%D0%B8%D1%8F-%D0%BF%D0%BE-%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B5-%D1%81-botfather-%D0%B1%D0%BE%D1%82%D0%BE%D0%BC-5c6f74d99a1a)
* [riemann.telegram](https://riemann.io/api/riemann.telegram.html)

# Ищем Telegram Group-ID

По инструкции есть нам необходимо узнать group-id. Моя ошибка была в том, что я использовал telegram id своего аккаунта.
Чтобы найти group-id нам понадобится следующий [бот](https://t.me/RawDataBot). Данный бот нужно добавить в группу, после нужно написать сообщение, любое сообщение.

Получите подобное сообщение:

```
{
    "update_id": XXXXXXXXX,
    "message": {
        "message_id": XXXXXX,
        "from": {
            "id": XXXXXXXXX,
            "is_bot": false,
            "first_name": "User",
            "username": "user"
        },
        "chat": {
            "id": -YYYYYYYYY,
            "title": "GroupName",
            "type": "group",
            "all_members_are_administrators": true
        },
        "date": XXXXXXXXX,
        "text": "\u041f\u0440\u0438\u0432\u0435\u0442"
    }
}
```

ID со знаком минусом - это нужный нам Group-ID.
Затем удаляем бота RawDataBot из группы, вставляем Group-ID в настройки Riemann Telegram Bot и ждем сообщений в группу.

**Дополнение**

Можно настроить Riemann на отсылку сообщений в различные группы, для этого нужно настроить разные Group-id.