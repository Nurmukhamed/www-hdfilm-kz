---
layout: page
title: "Біз қазақпыз и обратная совместимость"
date: 2022-03-02
comments: true
categories: 
- ubuntu
- bash
- qazaq
- linux
- DRY
---

** Небольшая памятка, что не наступать на грабли**
<!-- more -->

В ноябре 2021 окончательно перешел на Ubuntu. Купил жесткий диск, установил систему, создал пользователя. Все как обычно.

Но так как "Біз қазақпыз", то локаль была выбрана казахская и все теперь на казахском, что в принципе совсем не напрягало.

А вот что напрягало, то что Ubuntu создала в каталоге пользователя также на казахском языке.

В консоле приходилось набирать 
```
cd ~/Жүктемелер
```

Вот мой способ решения - создать symlinks на эти папки на английском языке и не переключать клавиатуру. Запустить один раз при первом входе и забыть.


```
cd ~
ln -s "Өлеңдер" Music
ln -s "Үлгілер" Templates
ln -s "Жүктемелер" Downloads
ln -s "Суреттер" Pictures
ln -s "Құжаттар" Documents
ln -s "Көпшілікке қол жетімді" Public
ln -s "Жұмыс үстелі" Desktop
ln -s "Видео" Videos
```
