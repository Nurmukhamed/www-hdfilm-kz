---
layout: post
title: Регистрация сервиса vault, когда работает consul server
date: '2020-09-08 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- hashicorp
- vault
- consul
- service discovery
---

**Регистрация сервиса vault, когда работает consul server** <!--more-->

На одном сервере запущен:

* consul в режиме server;
* vault

Упрощенно конфигурация следующая:

```
storage "consul" {
   address = "127.0.0.1:8500"
   path    = "vault/"
   scheme = "http"
}

```

В логах постоянно сыпится

```
end: error="service registration failed: Unexpected response code: 400 (Invalid
 error="Unexpected response code: 500 (Unknown check "vault:0.0.0.0:8200:vault-s
end: error="service registration failed: Unexpected response code: 400 (Invalid
 error="Unexpected response code: 500 (Unknown check "vault:0.0.0.0:8200:vault-s
end: error="service registration failed: Unexpected response code: 400 (Invalid
 error="Unexpected response code: 500 (Unknown check "vault:0.0.0.0:8200:vault-s
end: error="service registration failed: Unexpected response code: 400 (Invalid
 error="Unexpected response code: 500 (Unknown check "vault:0.0.0.0:8200:vault-s
end: error="service registration failed: Unexpected response code: 400 (Invalid
 error="Unexpected response code: 500 (Unknown check "vault:0.0.0.0:8200:vault-s
```

Решил это побороть, в итоге выяснил, что:

* Consul в режиме сервера и Vault не должны работать на одном сервере;
* Vault должен проводить регистрацию только на consul agent client.
* В противном случае нужно отключить регистрацию сервиса vault на consul

В конфиг нужно добавить одну строку:

```
storage "consul" {
   address = "127.0.0.1:8500"
   path    = "vault/"
   scheme = "http"
   disable_registration = true
}

```

**Итог:**

* Нужно следовать рекомендациям - не размещать на одном сервере consul, vault;
* Если не получается, то нужно отключить регистрацию сервиса vault;
