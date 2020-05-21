---
layout: page
title: "как заменить образ сетевой карты в виртуальной машине на образ ipxe"
date: 2015-07-24
comments: true
categories: 
- ipxe
- vmware
- powershell
- powercli
---

Небольшая статья - как заменить образ сетевой карты в виртуальной машине на образ ipxe.

<!-- more -->

На сайте ipxe нашел как можно заменить образы сетевой карты на свои. Но это все делается ручками.
Что делать, если у тебя виртуальных машин больше 100 и более.

Нужно автоматизировать данный процесс. Используем powershell и powercli. Также нам понадобятся putty, pscp.

Использовал информацию со следующих сайтов:

*   [Using plink to modify ESXi host configuration files via SSH from a PowerCLI script](http://www.shogan.co.uk/vmware/using-plink-to-modify-esxi-host-configuration-files-via-ssh-from-a-powercli-script/)
*   [Using iPXE in VMware](http://ipxe.org/howto/vmware)
*   [Changing VMX files just got a whole lot easier.](http://blogs.vmware.com/PowerCLI/2008/09/changing-vmx-fi.html)
*   [http://d.hatena.ne.jp/adsaria/20100623/1277255758](http://d.hatena.ne.jp/adsaria/20100623/1277255758)


**Создание образов**

{{< imgcap src="/images/10222000-web.png" caption="10222000-web.png" >}}
{{< imgcap src="/images/15ad07b0-web.png" caption="15ad07b0-web.png" >}}
{{< imgcap src="/images/8086100f-web.png" caption="8086100f-web.png" >}}
{{< imgcap src="/images/808610d3-web.png" caption="808610d3-web.png" >}}

Скрипт с поддержкой dhcp

```
#!ipxe

dhcp
chain http://boot.nurm.local/ipxe.php?mac=${net0/mac:hexhyp}
```

Скрипт со статическим адресом
```
#!ipxe

ifopen

set net0/ip 192.168.1.200
set net0/netmask 255.255.255.0
set net0/gateway 192.168.1.1
set net0/dns 192.168.1.1

chain http://boot.nurm.local/ipxe.php?mac=${net0/mac:hexhyp}
```



**Скрипт powershell**

```
Param(
[String]$ESXHost="192.168.1.2",
[String]$ESXUser="root",
[String]$ESXPass="123root123")

# Check PsSnapin Before Loading
if ( (Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PsSnapin VMware.VimAutomation.Core
}


#Connect to vcenter server first before starting script
Connect-VIServer -Server $ESXHost -User $ESXUser -Password $ESXPass

# Start the SSH service
$sshService = Get-VmHostService -VMHost $ESXHost | Where { $_.Key -eq "TSM-SSH"}
Start-VMHostService -HostService $sshService -Confirm:$false

# Run putty - create folder /usr/lib/vmware/resources, copy mrom files to esxi host
$RunPuttyCmd = @"
mkdir -p /usr/lib/vmware/resources
"@

$RunPuttyCmd           |Out-File -FilePath  commands.txt  -Force -encoding ASCII

$RunPuttyBat = @"
REM -----------------------------RunPuttyCmds.BAT------------------------------

    putty.exe -pw $ESXPass $ESXUser@$ESXHost -m commands.txt

    pscp.exe -pw $ESXPass -l $ESXUser *.mrom $($ESXHost):/usr/lib/vmware/resources/

REM -----------------------------End-of-Run-PuttyCmds.BAT----------------------
"@

$RunPuttyBat           |Out-File -FilePath  RunPuttyCmd.bat  -Force -encoding ASCII

Invoke-Expression -Command:".\RunPuttyCmd.bat"

Remove-Item -LiteralPath:"RunPuttyCmd.bat" -Force
Remove-Item -LiteralPath:"commands.txt" -Force

# Stop SSH service
Stop-VMHostService -HostService $sshService -Confirm:$false

$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.tools = New-Object VMware.Vim.ToolsConfigInfo

$extra1 = New-Object VMware.Vim.OptionValue
$extra1.Key = "ethernet0.opromsize"
$extra1.Value = "262144"
$spec.ExtraConfig += $extra1
$extra2 = New-Object VMware.Vim.OptionValue
$extra2.Key = "e1000bios.filename"
$extra2.Value = "/vmfs/volumes/datastore1/mrom/8086100f.mrom"
$spec.ExtraConfig += $extra2
$extra3 = New-Object VMware.Vim.OptionValue
$extra3.Key = "e1000ebios.filename"
$extra3.Value = "/vmfs/volumes/datastore1/mrom/808610d3.mrom"
$spec.ExtraConfig += $extra3
$extra4 = New-Object VMware.Vim.OptionValue
$extra4.Key = "nbios.filename"
$extra4.Value = "/vmfs/volumes/datastore1/mrom/10222000.rom"
$spec.ExtraConfig += $extra4
$extra5 = New-Object VMware.Vim.OptionValue
$extra5.Key = "nx3bios.filename"
$extra5.Value = "/vmfs/volumes/datastore1/mrom/15ad07b0.rom"
$spec.ExtraConfig += $extra5


$vms = get-vm | get-view

foreach($vm in $vms){
    Write-Host "Found VM $vm.Name"
    $vm.ReconfigVM($spec)
}

Disconnect-VIServer -Confirm:$false

```

Данный скрипт обновляет vmx файл ВМ, добавляет bootrom для сетевых карт. Работает даже на запущенных ВМ.

```
TODO - 
add example images before and after

```


**Результаты работы**
```
TODO -
add picture of running vms

в скрипте есть недостатки - 
* обновляет только первую сетевую карту - нужно изменить скрипт так, чтобы изменялась информация по всем сетевым картам.
* нужно отслеживать какой тип сетевой карты используется и добавлять информацию только данной карте.

```

