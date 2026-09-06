---
title: "Отзываю свой GPG ключ."
date: 2026-08-31T02:44:55+05:00
summary: ""
categories:
- GPG
- key
- revoke

---
Отзываю GPG ключ.
<!--more-->

Ну вдруг кому будет интересно, то вот стоит отозвать мой ключ.

~~~
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: This is a revocation certificate

iQI2BCABCgAgFiEEKAlsIt75haEfriE/qVRo8CsuKg4FAmqVCVACHQMACgkQqVRo
8CsuKg7bDw/6A8a0vD/RB83Zwa3cS8q7Kh5Yi5broitaP2G/oPfTBfaf85KrMaX3
Nf2MAC5Mni0+qBnuYBPdq2MFDhvCj6PlWxpZZXYM01J9/Y9bQyeZdoHxuMmAsalX
w3k8tCo5nQ4u1e8Fr0sC0In9KFWPiVbX3DfRGoUzyVlprJc7NI6xCueUkQo0UGn+
4Ygnwn4aN94X5lylglf0/8pbNRpdzd7DctD2ZcDARbGw+bh7dzhYYoCIbfqxnoUT
BdtTr2mbuTvjga3SvOIcsVGdimpy4lbroBRKY4V+UriFGykJQWhS0D3fu3X2jhOT
5r6+tfc95XCSaddlK8IpM2a9eux/ojYxb4gRkX1FxREDUW4rTO8P5MO7CKtFAhe3
YQ/nv7/PN6fZHgXxKeSrId0wFLKsYtlGCR1ZG8Te/j6w8vkqaItYds97A4JuHAlH
x57uF8OL2NzdXKCMDhYDNadX+m0T/BOTApYq3ikhXabbqqiSCcVJU4uIIvGwXKVS
BOOcEpeSPlVmCFpj4H1DKBDldk0L8s0E+VQfROT3XbwHH07XoCPgn1POHhCIG0e5
FkqtWmV6azGS1HvWhkBbpBGsHjGHrPiQapWRNABUEKd3NtlKcFriB6gQu3LEbgjb
0/9rxc02t3+mwRQkjiMp36cne8IavuHyo5cGtS8Gknz1D/vCeAc5WoA=
=MoaF
-----END PGP PUBLIC KEY BLOCK-----

~~~

~~~bash
gpg --import /path/to/your/revocation-certificate.asc

gpg --list-keys


~~~
