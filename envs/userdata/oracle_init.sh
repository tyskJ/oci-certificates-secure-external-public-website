#!/bin/bash

# Shell Options
# e : エラーがあったら直ちにシェルを終了
# u : 未定義変数を使用したときにエラーとする
# o : シェルオプションを有効にする
# pipefail : パイプラインの返り値を最後のエラー終了値にする (エラー終了値がない場合は0を返す)
set -euo pipefail

# Timezone
timedatectl set-timezone Asia/Tokyo
systemctl restart rsyslog

# Locale
localectl set-locale LANG=ja_JP.UTF-8
localectl set-keymap jp106

# Firewall Service disable
systemctl stop firewalld
systemctl disable firewalld
systemctl mask firewalld

# Apache Install
dnf install -y httpd
systemctl enable --now httpd
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html

# SELinux disable
grubby --update-kernel ALL --args selinux=0
shutdown -r now