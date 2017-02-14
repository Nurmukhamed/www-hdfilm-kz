---
layout: post
title: "Настройка групп на чтение, на запись в Amazon S3"
date: 2017-02-07 12:30:30 +0600
comments: true
published: false
categories: 
- amazon
- amazon s3
- amazon iam
- bucket
- security
- howto
---

Описание моего опыта работы с Amazon S3. Создание групп "на чтение", "на запись". <!--more-->

## Предыстория

В конце 2013 года я принял решение уйти с Dropbox, заканичивалась акция от Samsung Galaxy S3, по которой получил 50 Гб лишних. Решил перейти на Amazon S3. Создал новую учетную запись, создал новую корзину, закинул туда бакапы с рабочего компьютера, домашнего компьютера, архив изображений различных лет, Dropbox. Позже в 2014-2015 годах туда добавил сканы книг на казахском языке. Ежемесячный счет выходил в районе 10 долларов США. Тогда было не напряжно. В данный момент, я пошел дальше и перевел свои бакапы на Amazon Glacier, последний счет был в районе 6 долларов США. Меня все устраивает. 

## Страшные истории

В интернете полно историй о людях, которые использовали в своих проектах главную, основную учетную запись, затем становились жертвой хакеров. Хакеры запускали дюжины дорогих серверов и вычисляли биткоин. Затем, пользователи разбирались с Amazon по поводу счетов.

Для решения этой проблемы есть инструмент Amazon IAM. Суть в кратце - создать ограниченные учетные записи для определенных целей. Например, для запуска EC2, для записи в корзину Amazon S3 и так далее. Меня Amazon пару раз предупредил, что не хорошо использовать основные учетные записи для записи бакапов в Amazon S3 и предложил почитать о Amazon IAM. Что я и сделал. Создал учетку для Amazon S3. Но была проблема - с этой учеткой можно было делать все в моих корзинах. Нужно было найти другое решение. Я нашел два решения - первое - мое, второе - от Amazon.

## Пример №1 - отдельные корзины, отдельные пользователи

Мое решение:

- Amazon S3  - Создаем корзину для каждого проекта;
- Amazon IAM - Создаем группу "на чтение" и группу "на запись" для каждой корзины;
- Amazon IAM - Группе "на чтение" прикрепляем inline-политику;
- Amazon IAM - Группе "на запись" прикрепляем inline-политику;
- Amazon IAM - Создаем пользователей, прикрепляем к различным группам;
- Пользователи имеют ограниченный доступ к корзинам.

### Inline-политика на чтение
