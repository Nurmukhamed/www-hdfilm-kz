---
layout: post
title: Сборка блога переехала с Travis CI на Github Actions
date: '2020-09-06 12:30:30 +0600'
comments: true
published: true
categories:
- linux
- docker
- git
- github
- github actions
- ubuntu
---

**Сборка блога переехала с Travis CI на Github Actions** <!--more-->

После выхода [Github Actions](https://www.edwardthomson.com/blog/github_actions_1_cicd_triggers.html) возник - А зачем мне теперь [Travis CI](https://travis-ci.org/)??? Задал себе вопрос и отложил его в ТОДО-списке.

И вот в воскресное утро решил, что пришло время. 

* Прочитал [статью](https://github.com/peaceiris/actions-hugo);
* удалил файлы с секретами, которые нужно передавать в **Travis CI**;
* добавил простой workflow для сборки блога на [Github Actions](https://github.com/features/actions);
* cделал комиты, отправил (push) в [Github](https://github.com);
* все собралось. 

**Итог:**

* Удалились файлы с секретами;
* Все работает в одной экосистеме;
* Быстрее стала сборка.