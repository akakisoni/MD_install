#!/bin/bash
# install_majordomo.sh
# Tested on Ubuntu 22.04 LTS & 24.04 LTS (server / minimal)
# Majordomo + Apache + PHP 7.4 + MariaDB + phpMyAdmin
# All passwords are preset to: inkliminkli

###############################################################################
# 1. Общие настройки окружения
###############################################################################
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
PASS="inkliminkli"
DB_TIMEZONE="Europe/Moscow"       # поправьте при необходимости
PHP_VERSION="7.4"                 # мы ставим php7.4 из PPA Ondřej Surý

# Цветной вывод
GREEN='\033[1;32m'
NC='\033[0m' # No Color
function info() { printf "${GREEN}%b${NC}\n" "$*"; }

###############################################################################
# 2. Preseed паролей для MariaDB и phpMyAdmin
###############################################################################
info "⏳ Подготавливаю ответы для debconf…"

# MariaDB не запрашивает пароль в 22/24 LTS, но dbconfig-mysql сделает это.
# Сразу добавим root-пароль в debconf, чтобы phpMyAdmin мог подключиться.
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true"        | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-user string root"         | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${PASS}"    | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass   password ${PASS}"    | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${PASS}"| debconf-set-selections

###############################################################################
# 3. Репозитории, обновление и базовые пакеты
###############################################################################
info "🔧 Добавляю universe и PPA Ondřej Šurý (PHP)…"
add-apt-repository -y universe
apt-get update -qq
apt-get install -y -qq software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update -qq

info "📦 Устанавливаю системные пакеты…"
apt-get install -y -qq \
    git unzip net-tools language-pack-ru \
    apache2 apache2-utils libapache2-mod-php${PHP_VERSION} \
    php${PHP_VERSION} php${PHP_VERSION}-{mysql,common,json,opcache,readline,bz2,cli,curl,gd,mbstring,xml,bcmath,zip,mcrypt} \
    php-pear php${PHP_VERSION}-dev libmcrypt-dev gcc make autoconf libc6-dev pkg-config \
    mariadb-server mariadb-client dbconfig-mysql \
    wget

# Отключаем UFW и сон
systemctl disable --now ufw || true
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

###############################################################################
# 4. PECL mcrypt (автоматический ввод)
###############################################################################
info "🔌 Компилирую mcrypt для PHP ${PHP_VERSION}…"
yes '' | pecl install mcrypt-1.0.5 > /dev/null
echo "extension=mcrypt.so" > /etc/php/${PHP_VERSION}/mods-available/mcrypt.ini
phpenmod mcrypt

###############################################################################
# 5. Настройка MariaDB (root = inkliminkli, unix_socket → mysql_native_password)
###############################################################################
info "🗄️ Настраиваю MariaDB root-пароль…"
systemctl restart mariadb
mysql -uroot <<SQL
-- Меняем способ аутентификации и устанавливаем пароль
ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('${PASS}');
FLUSH PRIVILEGES;
SQL

###############################################################################
# 6. Устанавливаем phpMyAdmin в /var/www/phpmyadmin
###############################################################################
PMA_DIR="/var/www/phpmyadmin"
if [[ ! -d $PMA_DIR ]]; then
    info "🌐 Скачиваю phpMyAdmin…"
    wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.xz -O /tmp/pma.tar.xz
    mkdir -p "$PMA_DIR"
    tar -xf /tmp/pma.tar.xz -C "$PMA_DIR" --strip-components 1
    mkdir -p "$PMA_DIR/tmp"
    chmod 777 "$PMA_DIR/tmp"
    rm /tmp/pma.tar.xz
fi

###############################################################################
# 7. Настройка PHP и Apache
###############################################################################
info "🛠️ Тюнинг php.ini…"
for INI in /etc/php/${PHP_VERSION}/{apache2,cli}/php.ini; do
    sed -i 's/short_open_tag = Off/short_open_tag = On/' "$INI"
    sed -i 's/max_execution_time = 30/max_execution_time = 90/' "$INI"
    sed -i 's/max_input_time = 60/max_input_time = 180/' "$INI"
    sed -i 's/post_max_size = .*/post_max_size = 200M/' "$INI"
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 50M/' "$INI"
    sed -i 's/max_file_uploads = .*/max_file_uploads = 150/' "$INI"
done

info "🔃 Активирую mod_rewrite и перезапускаю Apache…"
a2enmod rewrite
echo "ServerName localhost" >> /etc/apache2/apache2.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
systemctl restart apache2

###############################################################################
# 8. Скачиваем и разворачиваем MajorDoMo
###############################################################################
info "⬇️ Качаю Majordomo…"
cd /usr/src
wget -q https://github.com/akakisoni/MyMD/raw/main/mjdm.zip -O mjdm.zip
unzip -qq mjdm.zip
cp -rp majordomo/* /var/www
cp -p  majordomo/.htaccess /var/www
cp    /var/www/config.php.sample /var/www/config.php
chown -R www-data:www-data /var/www
find /var/www/ -type f -exec chmod 666 {} \;
find /var/www/ -type d -exec chmod 777 {} \;

###############################################################################
# 9. MajorDoMo systemd-сервис
###############################################################################
info "🖇️ Добавляю majordomo.service…"
cat >/etc/systemd/system/majordomo.service <<EOF
[Unit]
Description=MajorDoMo
Requires=network.target mariadb.service apache2.service
After=network.target mariadb.service apache2.service

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/bin/php /var/www/cycle.php
ExecStop=/usr/bin/pkill -f cycle_*
Restart=on-failure
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now majordomo

###############################################################################
# 10. Настройка базы данных MajorDoMo
###############################################################################
info "🗂️ Создаю базу db_terminal…"
mysql -uroot -p${PASS} <<SQL
CREATE DATABASE IF NOT EXISTS db_terminal CHARACTER SET utf8 COLLATE utf8_general_ci;
SQL
mysql -uroot -p${PASS} db_terminal < /var/www/db_terminal.sql

mysql -uroot -p${PASS} db_terminal <<SQL
UPDATE pinghosts SET HOSTNAME='ya.ru';
UPDATE settings SET VALUE='dark' WHERE NAME='THEME';
INSERT INTO settings (TITLE,NAME,TYPE,NOTES,VALUE,DEFAULTVALUE,DATA)
  VALUES ('Language','SITE_LANGUAGE','text','ru','ru','ru','');
INSERT INTO settings (TITLE,NAME,TYPE,NOTES,VALUE,DEFAULTVALUE,DATA)
  VALUES ('Time zone','SITE_TIMEZONE','text','${DB_TIMEZONE}','${DB_TIMEZONE}','');
SQL

# Подставляем пароль в config.php
sed -i "s/DB_PASSWORD', ''.*/DB_PASSWORD', '${PASS}' );/" /var/www/config.php

###############################################################################
# 11. Завершение
###############################################################################
info "🧹 Чищу временные файлы…"
rm -rf /usr/src/{mjdm.zip,majordomo}

info "✅ Установка завершена!  
Логин в phpMyAdmin: root / ${PASS}  
Majordomo доступен по адресу: http://<IP-адрес-сервера>/"
