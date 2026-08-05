---
title: "Примеры kickstart, preseed.cfg файлов"
date: 2026-08-05T12:44:55+05:00
summary: ""
categories:
- netboot
- ipxe
- RockyLinux
- kickstart
- Debian
- preseeds
---

Дополнение к статье [Настраиваем сетевую загрузку с помощью mikrotik, ipxe, bios, uefi][1].

<!--more-->

Решил добавить примеры рабочих [kickstart][2], [preseeds.cfg][3] файлов, которые используются у меня для быстрой настройки операционных систем.

[Kickstart][2], [Preseed.cfg][3] файлы нужны для быстрой настройки операционной системы без нашего вмешательства. 

Нужно только запустить установку операционной системы и указать путь до Kickstart, Preseed файла. 
Дальше установшик самостоятельно настроит операционную систему.
Что экономит кучу времени и дает на выходе ясный и стабильный результат.

Основой для моих kickstart, preseed.cfg послужил [репозиторий от VMWARE][5].

# Пароль

Пароль для пользователя support - SuperPa$$w0rd.

Для генерации пароля нужно выполнить [команду][4].

~~~bash
openssl passwd -6
~~~


# Kickstart

Это kickstart файл для RockyLinux. Скорее всего этот файл также будет работать и для RHEL, AlmaLinux.


## 10

~~~
# Rocky Linux 10

url --url="http://mirror.ps.kz/rocky/10.2/BaseOS/x86_64/os"

text

eula --agreed
lang en_US.UTF-8
keyboard 'us'

network --device=eno1 --bootproto=dhcp

rootpw --lock

user --name=support --iscrypted --password=$6$RZiNVLtjx4DWjFzr$zIiuGa7lNlbBnSH0Gk9JRwmS4RuzhEQ0uAJOmdKVAkkWSVghhcaCBH5vmsxLce8H7KRw58qgCqZc3TK5dy.61/ --groups=wheel

firewall --enabled --ssh

authselect select sssd

selinux --enforcing

timezone Asia/Aqtobe

bootloader --location=mbr

zerombr

clearpart --all --initlabel

part /boot/efi --label=EFIFS --fstype vfat --size=1024
part /boot --label=BOOTFS --fstype xfs --size=1024
part pv.sysvg --size=100 --grow

volgroup sysvg pv.sysvg

logvol / --name=lv_root --vgname=sysvg --label=ROOTFS --fstype xfs --size=12288
logvol /home --name=lv_home --vgname=sysvg --label=HOMEFS --fstype xfs --fsoptions="nodev,nosuid" --size=4096
logvol /opt --name=lv_opt --vgname=sysvg --label=OPTFS --fstype xfs --fsoptions="nodev" --size=2048
logvol /tmp --name=lv_tmp --vgname=sysvg --label=TMPFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096
logvol /var --name=lv_var --vgname=sysvg --label=VARFS --fstype xfs --fsoptions="nodev" --size=4096
logvol /var/log --name=lv_log --vgname=sysvg --label=LOGFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096
logvol /var/log/audit --name=lv_audit --vgname=sysvg --label=AUDITFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096

services --enabled=NetworkManager,sshd

skipx

%packages --ignoremissing --excludedocs
@core
-iwl*firmware
%end

%post
dnf install -y sudo perl podman
echo "support ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/support
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end

reboot --eject
~~~


## 9

~~~
# Rocky Linux 9

url --url="http://mirror.ps.kz/rocky/9.8/BaseOS/x86_64/os"

text

eula --agreed
lang en_US.UTF-8
keyboard 'us'

network --device=eno1 --bootproto=dhcp

rootpw --lock

user --name=support --iscrypted --password=$6$RZiNVLtjx4DWjFzr$zIiuGa7lNlbBnSH0Gk9JRwmS4RuzhEQ0uAJOmdKVAkkWSVghhcaCBH5vmsxLce8H7KRw58qgCqZc3TK5dy.61/ --groups=wheel

firewall --enabled --ssh

authselect select sssd

selinux --enforcing

timezone Asia/Aqtobe

bootloader --location=mbr

zerombr

clearpart --all --initlabel

part /boot/efi --label=EFIFS --fstype vfat --size=1024
part /boot --label=BOOTFS --fstype xfs --size=1024
part pv.sysvg --size=100 --grow

volgroup sysvg pv.sysvg

logvol / --name=lv_root --vgname=sysvg --label=ROOTFS --fstype xfs --size=12288
logvol /home --name=lv_home --vgname=sysvg --label=HOMEFS --fstype xfs --fsoptions="nodev,nosuid" --size=4096
logvol /opt --name=lv_opt --vgname=sysvg --label=OPTFS --fstype xfs --fsoptions="nodev" --size=2048
logvol /tmp --name=lv_tmp --vgname=sysvg --label=TMPFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096
logvol /var --name=lv_var --vgname=sysvg --label=VARFS --fstype xfs --fsoptions="nodev" --size=4096
logvol /var/log --name=lv_log --vgname=sysvg --label=LOGFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096
logvol /var/log/audit --name=lv_audit --vgname=sysvg --label=AUDITFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096

services --enabled=NetworkManager,sshd

skipx

%packages --ignoremissing --excludedocs
@core
-iwl*firmware
%end

%post
dnf install -y sudo perl podman
echo "support ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/support
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end

reboot --eject
~~~


## 8

~~~
# Rocky Linux 8

url --url="http://mirror.ps.kz/rocky/8.10/BaseOS/x86_64/os"

text

eula --agreed
lang en_US.UTF-8
keyboard 'us'

network --device=eno1 --bootproto=dhcp

rootpw --lock

user --name=support --iscrypted --password=$6$RZiNVLtjx4DWjFzr$zIiuGa7lNlbBnSH0Gk9JRwmS4RuzhEQ0uAJOmdKVAkkWSVghhcaCBH5vmsxLce8H7KRw58qgCqZc3TK5dy.61/ --groups=wheel

firewall --enabled --ssh

authselect select sssd

selinux --enforcing

timezone Asia/Aqtobe

bootloader --location=mbr

zerombr

clearpart --all --initlabel

part /boot/efi --label=EFIFS --fstype vfat --size=1024
part /boot --label=BOOTFS --fstype xfs --size=1024
part pv.sysvg --size=100 --grow

volgroup sysvg pv.sysvg

logvol / --name=lv_root --vgname=sysvg --label=ROOTFS --fstype xfs --size=12288
logvol /home --name=lv_home --vgname=sysvg --label=HOMEFS --fstype xfs --fsoptions="nodev,nosuid" --size=4096
logvol /opt --name=lv_opt --vgname=sysvg --label=OPTFS --fstype xfs --fsoptions="nodev" --size=2048
logvol /tmp --name=lv_tmp --vgname=sysvg --label=TMPFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096
logvol /var --name=lv_var --vgname=sysvg --label=VARFS --fstype xfs --fsoptions="nodev" --size=4096
logvol /var/log --name=lv_log --vgname=sysvg --label=LOGFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096
logvol /var/log/audit --name=lv_audit --vgname=sysvg --label=AUDITFS --fstype xfs --fsoptions="nodev,noexec,nosuid" --size=4096

services --enabled=NetworkManager,sshd

skipx

%packages --ignoremissing --excludedocs
@core
-iwl*firmware
%end

%post
dnf install -y sudo perl podman
echo "support ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/support
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end

reboot --eject
~~~

# Preseed.cfg

Я использую только Debian, preseed.cfg для bookworm, trixie. 
В более старых версиях использовался другой формат.

## bookworm

~~~
# Locale
d-i debian-installer/locale string en_US
d-i debian-installer/language string en
d-i debian-installer/country string KZ
# Optionally specify additional locales to be generated.
d-i localechooser/supported-locales multiselect en_US.UTF-8, ru_RU.UTF-8

# Clock and Timezone
d-i clock-setup/utc boolean true
d-i clock-setup/ntp boolean true
d-i time/zone string Asia/Aqtobe

# Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string mirror.ps.kz
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

# Package Configuration
d-i pkgsel/run_tasksel boolean false
d-i pkgsel/include string openssh-server python3-apt perl curl podman

# User configuration
d-i passwd/root-login boolean false

d-i passwd/make-user boolean true
d-i passwd/user-fullname string Support
d-i passwd/username string support
d-i passwd/user-password-crypted password $6$RZiNVLtjx4DWjFzr$zIiuGa7lNlbBnSH0Gk9JRwmS4RuzhEQ0uAJOmdKVAkkWSVghhcaCBH5vmsxLce8H7KRw58qgCqZc3TK5dy.61/
d-i passwd/user-uid string 1000

# Add User to Sudoers
d-i preseed/late_command string \
    echo 'support ALL=(ALL) NOPASSWD: ALL' > /target/etc/sudoers.d/support ; \
    in-target chmod 440 /etc/sudoers.d/support ; \
    mkdir /target/home/support/.ssh ; \
    echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYCiZieZsL9dB1uQzNWiVyETThr8l57vPOySDz6WVye support@somehost' > /target/home/support/.ssh/authorized_keys ; \
    chmod 0600 /target/home/support/.ssh/authorized_keys ; \
    chmod 0700 /target/home/support/.ssh ; \
    chown 1000:1000 -R /target/home/support/.ssh ;

# Grub and Reboot Message
d-i finish-install/reboot_in_progress note
d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string /dev/sda

# Partitioning
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string lvm
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-auto-lvm/new_vg_name string sysvg

# Force UEFI booting (BIOS compatibility will be lost). Default: false.
d-i partman-efi/non_efi_system boolean true

# Ensure the partition table is GPT - this is required for EFI
d-i partman-partitioning/choose_label select gpt
d-i partman-partitioning/default_label string gpt

d-i partman-basicfilesystems/no_swap boolean false
d-i partman-auto/expert_recipe string \
  custom :: \
    1024 1024 1024 fat32 \
    $primary{ } \
    mountpoint{ /boot/efi } \
    method{ efi } \
    format{ } \
    use_filesystem{ } \
    filesystem{ vfat } \
    label { EFIFS } \
    . \
    1024 1024 1024 xfs \
    $primary{ } \
    $bootable{ } \
    mountpoint{ /boot } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { BOOTFS } \
    . \
    12288 12288 12288 xfs \
    $lvmok{ } \
    mountpoint{ / } \
    lv_name{ lv_root } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { ROOTFS } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /home } \
    lv_name{ lv_home } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { HOMEFS } \
    options/nodev{ nodev } \
    options/nosuid{ nosuid } \
    . \
    2048 2048 2048 xfs \
    $lvmok{ } \
    mountpoint{ /opt } \
    lv_name{ lv_opt } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { OPTFS } \
    options/nodev{ nodev } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /tmp } \
    lv_name{ lv_tmp } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { TMPFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /var } \
    lv_name{ lv_var } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { VARFS } \
    options/nodev{ nodev } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /var/log } \
    lv_name{ lv_log } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { LOGFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /var/log/audit } \
    lv_name{ lv_audit } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { AUDITFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /tmp/dump } \
    lv_name{ lv_tmp_dump } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { TMPDUMPFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \

d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i netcfg/choose_interface select eno1
~~~

## Trixie

~~~
# Locale
d-i debian-installer/locale string en_US
d-i debian-installer/language string en
d-i debian-installer/country string KZ
#Optionally specify additional locales to be generated
d-i localechooser/supported-locales multiselect en_US.UTF-8, ru_RU.UTF-8

# Clock and Timezone
d-i clock-setup/utc boolean true
d-i clock-setup/ntp boolean true
d-i time/zone string Asia/Aqtobe

# Mirror settings
d-i mirror/country string manual
d-i mirror/http/hostname string mirror.ps.kz
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

# Package Configuration
d-i pkgsel/run_tasksel boolean false
d-i pkgsel/include string openssh-server python3-apt perl curl

# User configuration
d-i passwd/root-login boolean false

d-i passwd/make-user boolean true
d-i passwd/user-fullname string Support
d-i passwd/username string support
d-i passwd/user-password-crypted password $6$RZiNVLtjx4DWjFzr$zIiuGa7lNlbBnSH0Gk9JRwmS4RuzhEQ0uAJOmdKVAkkWSVghhcaCBH5vmsxLce8H7KRw58qgCqZc3TK5dy.61/
d-i passwd/user-uid string 1000

# Add User to Sudoers
d-i preseed/late_command string \
    echo 'support ALL=(ALL) NOPASSWD: ALL' > /target/etc/sudoers.d/support ; \
    in-target chmod 440 /etc/sudoers.d/support ; \
    mkdir /target/home/support/.ssh ; \
    echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYCiZieZsL9dB1uQzNWiVyETThr8l57vPOySDz6WVye support@somehost' > /target/home/support/.ssh/authorized_keys ; \
    chmod 0600 /target/home/support/.ssh/authorized_keys ; \
    chmod 0700 /target/home/support/.ssh ; \
    chown 1000:1000 -R /target/home/support/.ssh ;

# Grub and Reboot Message
d-i finish-install/reboot_in_progress note
d-i grub-installer/only_debian boolean true
d-i grub-installed/bootdev string /dev/sda

# Partitioning
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string lvm
d-i partman-lvm/confirm boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-auto-lvm/new_vg_name string sysvg

# Force UEFI booting (BIOS compatibility will be lost). Default: false.
d-i partman-efi/non_efi_system boolean true

# Ensure the partition table is GPT - this is required for EFI
d-i partman-partitioning/choose_label select gpt
d-i partman-partitioning/default_label string gpt

d-i partman-basicfilesystems/no_swap boolean false
d-i partman-auto/expert_recipe string \
  custom :: \
    1024 1024 1024 fat32 \
    $primary{ } \
    mountpoint{ /boot/efi } \
    method{ efi } \
    format{ } \
    use_filesystem{ } \
    filesystem{ vfat } \
    label { EFIFS } \
    . \
    1024 1024 1024 xfs \
    $primary{ } \
    $bootable{ } \
    mountpoint{ /boot } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { BOOTFS } \
    . \
    12288 12288 12288 xfs \
    $lvmok{ } \
    mountpoint{ / } \
    lv_name{ lv_root } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { ROOTFS } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /home } \
    lv_name{ lv_home } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { HOMEFS } \
    options/nodev{ nodev } \
    options/nosuid{ nosuid } \
    . \
    2048 2048 2048 xfs \
    $lvmok{ } \
    mountpoint{ /opt } \
    lv_name{ lv_opt } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { OPTFS } \
    options/nodev{ nodev } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /tmp } \
    lv_name{ lv_tmp } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { TMPFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /var } \
    lv_name{ lv_var } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { VARFS } \
    options/nodev{ nodev } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /var/log } \
    lv_name{ lv_log } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { LOGFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \
    4096 4096 4096 xfs \
    $lvmok{ } \
    mountpoint{ /var/log/audit } \
    lv_name{ lv_audit } \
    in_vg { sysvg } \
    method{ format } \
    format{ } \
    use_filesystem{ } \
    filesystem{ xfs } \
    label { AUDITFS } \
    options/nodev{ nodev } \
    options/noexec{ noexec } \
    options/nosuid{ nosuid } \
    . \

d-i partman-partitioning/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
d-i partman/confirm_nooverwrite boolean true
d-i netcfg/choose_interface select eno1
~~~

[1]: https://hdfilm.kz/blog/2025/10/21/ipxe-strikes-back-in-2025/
[2]: https://en.wikipedia.org/wiki/Kickstart_(Linux)
[3]: https://en.wikipedia.org/wiki/Preseed
[4]: https://docs.rockylinux.org/10/guides/automation/kickstart-rocky/
[5]: https://github.com/vmware/packer-examples-for-vsphere/tree/develop

