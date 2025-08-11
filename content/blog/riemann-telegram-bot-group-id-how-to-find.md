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

# Update: 2025-08-11
Сегодня получил письмо.

```
Hey, I checked out your post and noticed the link for the BotFather
guide doesn’t seem to work. Any idea where I could find it? Here’s the
post I’m talking about:
https://hdfilm.kz/blog/2021/02/27/riemann-telegram-bot-group-id-how-to-find/.
Thanks a bunch!
```

Посмотрел ссылки, действительно не работают. Исправляем.

# Предыстория

История о моих ошибках при настройке Telegram Bot для системы мониторинга Riemann. <!-- more --> 
Поставили задачу создать новую группу в телеграме и подключить в эту группу. Вроде все сделал по мануалам, только оповещения приходят только мне. В группу не приходят.

# Инструкции

* [Инструкция по созданию и настройки бота в BotFather](https://docs.radist.online/radist.online-docs/nashi-produkty/radist-web/podklyucheniya/telegram-bot/instrukciya-po-sozdaniyu-i-nastroiki-bota-v-botfather)
* [Создание и настройка Телеграм бота | Руководство по BotFather ](https://www.youtube.com/watch?v=VRlpyIdNX1w)
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
