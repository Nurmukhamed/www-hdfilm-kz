---
layout: page
title: "Область видимости в шаблонах Helm."
date: 2025-02-23
comments: true
categories:
- kubernetes
- helm
- templates
- blunt
---

История в которой я потерял день пытаясь понять разницу между ":=" и "=" в helm templates.
Также про область видимости.
<!--more-->

**Пример**

У нас создан helm chart, в values.yaml объявим список **myBucket** со следующими элементами **apple, orange, lemon, potato**.

```yaml
myBucket:
  - apple
  - orange
  - lemon
  - potato
```

В шаблоне необходимо проверить корзину на наличие фруктов. Вначале я написал следующий код

```yaml
---
{{- $isFruitInMyBucket := false }}
{{- range $bucketElement := .Values.myBucket }}
{{-   if eq "apple" $bucketElement }}
{{-     $isFruitInMyBucket := true }}
{{-   else if eq "orange" $bucketElement }}
{{-     $isFruitInMyBucket := true }}
{{-   else if eq "lemon"  $bucketElement }}
{{-     $isFruitInMyBucket := true }}
{{-   end }}
{{- end }}
someFruitsInBucket: {{ $isFruitInMyBucket }}
```

Результат работы шаблона.

~~~bash
helm template .
---
# Source: testchart/templates/testfruit.yaml
someFruitsInBucket: false
~~~

Начал разбираться и нашел следующее. 

**Область видимости**, если переменная объявлена в некой области видимости (внутри цикла, условия) через ":=", то будет объявлена новая переменная, доступная только внутри этой области видимости. 
Если вместо ":=" использовать "=", то helm (скорее gotemplate) возмет эту переменную из родительской области видимости, изменить значение переменной, которое будет также сохранится и в родительской области видимости.

Переписываем шаблон правильным образом.

```yaml
---
{{- $isFruitInMyBucket := false }}
{{- range $bucketElement := .Values.myBucket }}
{{-   if eq "apple" $bucketElement }}
{{-     $isFruitInMyBucket = true }}
{{-   else if eq "orange" $bucketElement }}
{{-     $isFruitInMyBucket = true }}
{{-   else if eq "lemon"  $bucketElement }}
{{-     $isFruitInMyBucket = true }}
{{-   end }}
{{- end }}
someFruitsInBucket: {{ $isFruitInMyBucket }}
```

Результат работы шаблона.

~~~bash
helm template .
---
# Source: testchart/templates/testfruit.yaml
someFruitsInBucket: true
~~~
