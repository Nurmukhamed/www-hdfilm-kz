---
layout: post
title: Простой пример работы с массивами в jq
date: '2023-08-02 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- json
- jq
- vault
- bash
- curl3
---

**Простой пример работы с массивами в jq** <!--more-->

Сохраню здесь, вдруг завтра придется вспоминать как это делается.

```bash
certificates_json="$(curl \
    --silent \
    --request POST \
    --data "{\"common_name\": \"example.com\"}" \
    --header "X-Vault-Token: $VAULT_TOKEN" \
    $VAULT_ADDR/v1/pki/issue/example-dot-com)"

count=$(echo $certificate_json |
    jq -r '.data.ca_chain | length')

for ((i=0; i<$count; i++)); do
    echo $certificates_json |
    jq -r '.data.ca_chain['$i']' |
    tee -a ./tls/ca.pem > /dev/null
done
```

