---
layout: post
title: Неявное поведение consul watches при обновление. 
date: '2020-10-18 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- hashicorp
- consul
- watches
---

**Неявное поведение consul watches при обновление.** <!--more-->

**Проблема** - настроен кластер consul, каждые сутки происходит обновление сертификатов, делается consul reload.
Возникает проблема - consul начинает считывает все watches, которые consul должен отслеживать и начинает запускать скрипты.

**Изучение** - Имеем в consul настроенный [watches](https://www.consul.io/docs/dynamic-app-config/watches)

```json
{
 "watches": [
  {
   "type": "key",
   "key": "foo/bar/baz",
   "args": [ "/usr/local/bin/somescript.sh" ],
   "token": "some-token"
  }
 ]
}
```

Если мы поместим данные в KV Consul, то Consul добавит TTL к этой записи. И после истечения TTL, запись будет удалена.

**Варианты**:

| Ключ существует?  | Значение   |
|-------------------|------------|
| Не существует     | Null       |
| Старое значение   | JSON       |
| Новое значение    | JSON       |

Необходимо учитывает это поведение в скрипте. Отслеживать, когда получаем из STDIN значение Null, когда получаем JSON, 
то отслеживать старое или новое значение передано в скрипт.

