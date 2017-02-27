---
layout: post
title: 'Cisco VOIP - учимся писать dialplan, dialpeer'
date: '2017-02-21 12:30:30 +0600'
comments: true
published: true
categories:
  - cisco
  - avaya defenity
  - asterisk
  - Kazakhtelecom
  - E1 channel
---

В данной статье о моем опыте настройки Cisco 2811 в связке с Asterisk и Avaya Defenity. Черновик статьи лежал у меня в течение года. Решил опубликовать сегодня <!--more-->

##Предыстория: 

В далеких 2007-2009 годах, в одном офисе стояла АТС Avaya, подключенная Е1-потоком к Казахтелекому. В один день руководство решило, что нужно настроить «железную тетку», голосовую почту, конференции, дешевые тарифы через VOIP-провайдеров. В качестве дешевого решения предложил к АТС подключить Asterisk и на базе Asterisk реализовать умный функционал АТС.  В качестве sip-e1-шлюза был выбран роутер Cisco 2811 + 2Е1. В то время я еще не знал, что есть такая замечательная компания [Парабел](http://www.parabel.ru), которая выпускает не дорогие E1-платы для Asteriskа.

****Входные данные:****

****Казахтелеком:****

- Количество е1-потоков – 1, 30 каналов;
- Количество телефонных номеров – 2;
- Номер – 252525;
- Номер – 363636;
- Plan – national;
- Type – isdn.

****Avaya:****

- Количество внутренних линий – 96 (макс);
- Количество потоков е1 – 1;

****Cisco:****

- Количество PVDM2-32 – 2;
- Количество потоков е1 – 2;

****Номерной план офиса:****

- 10ХХ,11XX – номера на АТС Avaya;
- 12XX – номера на Asterisk;
- 252525 – входящий номер для IVR;
- 363636 – входящий номер на ресепшн;
- 1ХХ – экстренные и служебные номера Казахтелекома;
- 2ХХХХХХ, 3ХХХХХХ – исходящий звонок в город;
- 8ХХХХХХХХХХ – исходящий междугородний звонок в РК и РФ;
- 810. – исходящий международный звонок.

****Задача:****

****Настроить Cisco следующим образом:****

- При звонке на номер 252525, отправлять звонок на asterisk, на «железную тетку»;
- При звонке на номер 363636, отправлять звонок на avaya, на ресепшн;
- При звонке с АТС на Астериск, отправлять звонок на asterisk;
- При звонке с Asterisk на АТС, отправлять звонок на Avaya;
- При звонке с АТС  в город – отправлять звонок на Казахтелеком;
- При звонке с АТС на межгород – отправлять звонки на Asterisk, если Asterisk не доступен, отправлять звонки на Казахтелеком;

****Грабли:****

- Основной проблемой было понять, как работают dial-peer в cisco. Чтение google дало основную информацию, но ее было не достаточно;
- В asterisk есть понятие context для транка, любой входящий вызов идет в этот контекст, где происходит обработка звонка. В циске такого понятия нет. Нужно уметь отлавливать входящие звонки;
- В чем различие между calling number (набирающий? номер) и called number(набранный номер);


****Решение:****


В визио составил описание процесса звонка в cisco. 

{% img https://s3-eu-west-1.amazonaws.com/images.hdfilm.kz/kazakhtelecom-incoming.png %}

Ниже часть конфиг-файла с циски, рабочий:

{% highlight bash %}
!
isdn switch-type primary-net5
isdn voice-call-failure 0
!
voice-card 0
 no dspfarm
!
voice-card 1
 no dspfarm
!
voice rtp send-recv
!
voice service voip
 allow-connections sip to sip
 fax protocol t38 ls-redundancy 0 hs-redundancy 0 fallback pass-through g711alaw
 sip
!
voice class codec 1
 codec preference 1 g711alaw
 codec preference 2 g711ulaw
!
voice class custom-cptone 100
 dualtone busy
  frequency 430
  cadence 350 350
 dualtone disconnect
  frequency 425 435
  cadence 350 continuous
!
voice translation-rule 1
 rule 1 /^\(.*\)$/ /11111\1/ type any national plan any isdn
!
voice translation-rule 2
 rule 2 /^\(.*\)$/ /22222\1/ type any national plan any isdn
!
voice translation-rule 3
 rule 1 /^33333\(.*\)$/ /\1/ type any national plan any isdn
!
voice translation-rule 4
 rule 1 /^44444\(.*\)$/ /\1/ type any national plan any isdn
!
voice translation-rule 5
 rule 1 // // type any national plan any isdn
!
voice translation-rule 6
 rule 1 /^11111\(.*\)/ /44444\1/ type any national plan any isdn
!
voice translation-rule 7
 rule 1 /^22222\(.*\)/ /33333\1/ type any national plan any isdn
!
voice translation-rule 8
 rule 1 /^11111\(.*\)$/ /\1/ type any national plan any isdn
!
voice translation-rule 9
 rule 1 /^22222\(.*\)$/ /\1/ type any national plan any isdn
!
!
voice translation-profile fromAvaya
 translate calling 5
 translate called 2
!
voice translation-profile fromAvayatoCisco
 translate calling 5
 translate called 9
!
voice translation-profile fromAvayatoTelecom
 translate calling 5
 translate called 7
!
voice translation-profile fromTelecom
 translate calling 5
 translate called 1
!
voice translation-profile fromTelecomtoAvaya
 translate calling 5
 translate called 6
!
voice translation-profile fromTelecomtoCisco
 translate calling 5
 translate called 8
!
voice translation-profile toAvaya
 translate calling 5
 translate called 4
!
voice translation-profile toTelecom
 translate calling 5
 translate called 3
!
controller E1 1/0
 framing NO-CRC4
 pri-group timeslots 1-31
!
controller E1 1/1
 framing NO-CRC4
 pri-group timeslots 1-31
!
interface Serial1/0:15
 no ip address
 encapsulation hdlc
 no logging event link-status
 isdn switch-type primary-net5
 isdn incoming-voice voice
 isdn send-alerting
 isdn bchan-number-order ascending
 isdn sending-complete
 no keepalive
 no cdp enable
!
interface Serial1/1:15
 no ip address
 encapsulation hdlc
 no logging event link-status
 isdn switch-type primary-net5
 isdn protocol-emulate network
 isdn incoming-voice voice
 isdn send-alerting
 isdn sending-complete
 no keepalive
 no cdp enable
!
voice-port 1/0:15
 translation-profile incoming fromTelecom
 translation-profile outgoing toTelecom
 cptone RU
!
voice-port 1/1:15
 translation-profile incoming fromAvaya
 translation-profile outgoing toAvaya
 cptone RU
!
dial-peer voice 100 pots
 incoming called-number 252525
 direct-inward-dial
 port 1/0:15
!
dial-peer voice 101 pots
 incoming called-number 363636
 direct-inward-dial
 port 1/0:15
!
dial-peer voice 102 voip
 destination-pattern 11111252525
 progress_ind progress enable 8
 monitor probe icmp-ping
 session protocol sipv2
 session target ipv4:ASTERISKIP
 dtmf-relay rtp-nte h245-signal h245-alphanumeric
 codec g711alaw
 vad aggressive
!
dial-peer voice 103 pots
 translation-profile outgoing fromTelecomtoAvaya
 destination-pattern 11111363636
 port 1/1:15
 forward-digits all
!
dial-peer voice 104 pots
 incoming called-number 12..
 direct-inward-dial
 port 1/1:15
!
dial-peer voice 105 pots
 incoming called-number [23]......
 direct-inward-dial
 port 1/1:15
!
dial-peer voice 106 pots
 incoming called-number 8T
 direct-inward-dial
 port 1/1:15
!
dial-peer voice 107 voip
 destination-pattern 22222T
 progress_ind progress enable 8
 monitor probe icmp-ping
 session protocol sipv2
 session target ipv4:ASTERISKIP
 dtmf-relay rtp-nte h245-signal h245-alphanumeric
 codec g711alaw
 vad aggressive
!
dial-peer voice 108 pots
 translation-profile outgoing fromAvayatoCisco
 destination-pattern 22222[23]......
 port 1/0:15
 forward-digits all
!
dial-peer voice 109 pots
 incoming called-number [01]..
 direct-inward-dial
 port 1/1:15
!
dial-peer voice 110 pots
 translation-profile outgoing fromAvayatoTelecom
 destination-pattern 22222[01]..
 port 1/0:15
 forward-digits all
!
dial-peer voice 111 voip
 destination-pattern 2222212..
 progress_ind progress enable 8
 monitor probe icmp-ping
 session protocol sipv2
 session target ipv4:ASTERISKIP
 dtmf-relay rtp-nte h245-signal h245-alphanumeric
 codec g711alaw
 vad aggressive
!
dial-peer voice 112 pots
 translation-profile outgoing toAvaya
 destination-pattern 1[01]..
 port 1/1:15
 forward-digits all
!
dial-peer voice 113 pots
 translation-profile outgoing fromAvayatoTelecom
 preference 1
 destination-pattern 22222T
 port 1/0:15
 forward-digits all
!
dial-peer voice 114 voip
 translation-profile outgoing fromAvayatoCisco
 destination-pattern 222228..........
 progress_ind progress enable 8
 monitor probe icmp-ping
 session protocol sipv2
 session target ipv4:ASTERISKIP
 dtmf-relay rtp-nte h245-signal h245-alphanumeric
 codec g711alaw
 vad aggressive
!
dial-peer voice 115 pots
 translation-profile outgoing fromAvayatoTelecom
 preference 1
 destination-pattern 222228..........
 port 1/0:15
 forward-digits all
!
sip-ua
 authentication username cisco password 014356540C5A275E741C195C4D504E472E59217D7B
 retry invite 3
 retry response 3
 retry bye 3
 retry cancel 3
 timers trying 1000
 sip-server ipv4:ASTERISKIP
!
{% endhighlight %}
****TODO****: дописать статью
