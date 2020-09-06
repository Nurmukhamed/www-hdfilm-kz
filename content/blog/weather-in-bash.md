---
layout: page
title: "Bash: Показываем текущую погоду при входе в систему"
date: 2016-09-23
comments: true
categories: 
- bash
- linux
- weather
---

Сегодня на linux.org.ru нашел забавную [ссылку](https://www.linux.org.ru/forum/general/12895430?lastmod=1474565945023)
<!--more-->

Не долго думая решил, что надо показывать погоду в Астане при каждом входе в систему. 

Изменил ~/.bashrc нужным образом

```
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting

alias systemctl='sudo systemctl'
alias svim='sudo vim'
alias nsenter='sudo /usr/local/bin/nsenter.sh'

sprunge() {
    if [[ $1 ]]; then
            curl -F 'sprunge=<-' "http://sprunge.us" <"$1"
    else
            curl -F 'sprunge=<-' "http://sprunge.us"
    fi
}

curl -s wttr.in/Astana  | head -7 | tail -n+2
```

Проверил, работает.

