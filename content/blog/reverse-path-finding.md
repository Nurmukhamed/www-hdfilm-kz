---
layout: page
title: "Одна из задач."
date: 2025-02-19
comments: true
categories: 
- common
---

Сегодня забавным способом решил одну задачу.

**Задача**

Есть каталог /home/nartykaly/git/project1/folder1/folder2/folder3. Вы находитесь в этом каталоге и нужно вытащить в переменную значение каталога на 2 уровня.
В нашем примере значение переменной должно быть folder1.

**Решение**

Одно из решений

~~~bash
export PROJECT_NAME=$(pwd | rev | cut -d "/" -f 3 | rev)
echo ${PROJECT_NAME}
~~~
