#!/bin/bash
# Codepage UTF-8

### Ообавление репов Universe в Ubuntu server
add-apt-repository -y universe
### Обновляем информацию о репозиториях
sudo apt update
### Проверяем установлена ли русская локаль и если нет то устанавливаем
loc=$(apt-cache policy language-pack-ru)
if echo $loc | grep -q -s -F "(none)"; then
sudo apt install -y language-pack-ru
fi
### Останавливаем UFW
sudo ufw disable
sudo systemctl stop ufw
sudo systemctl disable ufw
### Выключаем засыпание
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
### Проверка версии Ubuntu\Mint и установка пакетов
echo "\033[1;32m определяю версию Ubuntu \033[0m"
ubnt=$(cat /etc/issue.net)
############################
#### Ubuntu 18 \ Mint 19 ###
if echo $ubnt | grep -q -s -F "Ubuntu 18" || echo $ubnt | grep -q -s -F "Mint 19"; then
echo "\033[1;32m $ubnt \033[0m"
### Устанавливаем необходимые пакеты
sudo apt install -y git
sudo apt install -y unzip
sudo apt install -y apache2
sudo apt install -y apache2-bin
sudo apt install -y apache2-data
sudo apt install -y apache2-utils
sudo apt install -y libapache2-mod-php7.2
sudo apt install -y libcurl3
sudo apt install -y php7.2
sudo apt install -y php7.2-mysql
sudo apt install -y php7.2-common
sudo apt install -y php7.2-json
sudo apt install -y php7.2-opcache
sudo apt install -y php7.2-readline
sudo apt install -y php7.2-bz2
sudo apt install -y php7.2-cli
sudo apt install -y php7.2-curl
sudo apt install -y php7.2-gd
sudo apt install -y php7.2-mbstring
sudo apt install -y php7.2-xml
sudo apt install -y php7.2-bcmath
sudo apt install -y php-pear
sudo apt install -y php7.2-dev
sudo apt install -y libmcrypt-dev
sudo apt install -y gcc
sudo apt install -y make
sudo apt install -y autoconf
sudo apt install -y libc6-dev
sudo apt install -y pkg-config
sudo pecl update-channels
sudo pear update-channels
echo "\033[1;32m на ожидании ввода libmcrypt prefix - просто нажмите ENTER \033[0m"
# будет ожидать ввода libmcrypt prefix - просто нажать ENTER
sudo pecl install mcrypt-1.0.3
sudo apt install -y dbconfig-mysql
sudo apt install -y mariadb-common
sudo apt install -y mariadb-client-10.1
sudo apt install -y mariadb-server-10.1
sudo apt install -y phpmyadmin

### Настраиваем PHP для Apache
echo "extension=mcrypt.so" | sudo tee -a /etc/php/7.2/apache2/conf.d/mcrypt.ini
sudo sed -i '/short_open_tag/s/Off/On/' /etc/php/7.2/apache2/php.ini
sudo sed -i '/error_reporting/s/~E_DEPRECATED & ~E_STRICT/~E_NOTICE/' /etc/php/7.2/apache2/php.ini
sudo sed -i '/max_execution_time/s/30/90/' /etc/php/7.2/apache2/php.ini
sudo sed -i '/max_input_time/s/60/180/' /etc/php/7.2/apache2/php.ini
sudo sed -i '/post_max_size/s/8/200/' /etc/php/7.2/apache2/php.ini
sudo sed -i '/upload_max_filesize/s/2/50/' /etc/php/7.2/apache2/php.ini
sudo sed -i '/max_file_uploads/s/20/150/' /etc/php/7.2/apache2/php.ini
### Настраиваем PHP для коммандной строки
sudo sed -i '/short_open_tag/s/Off/On/' /etc/php/7.2/cli/php.ini
fi

###########################
### Ubuntu 20 \ Mint 20 ###
if echo $ubnt | grep -q -s -F "Ubuntu 20" || echo $ubnt | grep -q -s -F "Mint 20"; then
echo "\033[1;32m $ubnt \033[0m"
### Устанавливаем необходимые пакеты
sudo apt install -y git
sudo apt install -y apache2
sudo apt install -y apache2-bin
sudo apt install -y apache2-data
sudo apt install -y apache2-utils
sudo apt install -y libapache2-mod-php7.4
sudo apt install -y libcurl4
sudo apt install -y php7.4
sudo apt install -y php7.4-mysql
sudo apt install -y php7.4-common
sudo apt install -y php7.4-json
sudo apt install -y php7.4-opcache
sudo apt install -y php7.4-readline
sudo apt install -y php7.4-bz2
sudo apt install -y php7.4-cli
sudo apt install -y php7.4-curl
sudo apt install -y php7.4-gd
sudo apt install -y php7.4-mbstring
sudo apt install -y php7.4-xml
sudo apt install -y php7.4-bcmath
sudo apt install -y php-pear
sudo apt install -y php7.4-dev
sudo apt install -y libmcrypt-dev
sudo apt install -y gcc
sudo apt install -y make
sudo apt install -y autoconf
sudo apt install -y libc6-dev
sudo apt install -y pkg-config
sudo pecl update-channels
sudo pear update-channels
echo "\033[1;32m на ожидании ввода libmcrypt prefix - просто нажмите ENTER \033[0m"
# будет ожидать ввода libmcrypt prefix - просто нажать ENTER
sudo pecl install mcrypt-1.0.3
sudo apt install -y dbconfig-mysql
sudo apt install -y mariadb-common
sudo apt install -y mariadb-client-10.3
sudo apt install -y mariadb-server-10.3
sudo apt install -y phpmyadmin

### Настраиваем PHP для Apache
echo "extension=mcrypt.so" | sudo tee -a /etc/php/7.4/apache2/conf.d/mcrypt.ini
sudo sed -i '/short_open_tag/s/Off/On/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/error_reporting/s/~E_DEPRECATED & ~E_STRICT/~E_NOTICE/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/max_execution_time/s/30/90/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/max_input_time/s/60/180/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/post_max_size/s/8/200/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/upload_max_filesize/s/2/50/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/max_file_uploads/s/20/150/' /etc/php/7.4/apache2/php.ini
### Настраиваем PHP для коммандной строки
sudo sed -i '/short_open_tag/s/Off/On/' /etc/php/7.4/cli/php.ini
fi

#######################################################
### Ubuntu 22                                       ###
### ОСОБЫЕ настройки mariadb и установка phpmyadmin ###
if echo $ubnt | grep -q -s -F "Ubuntu 22"; then
echo "\033[1;32m $ubnt \033[0m"
sudo locale-gen en_US.UTF-8
sudo update-locale
sudo apt purge -y needrestart
### Устанавливаем репо для php7
sudo apt install software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update
### Устанавливаем необходимые пакеты
sudo apt install -y git
sudo apt install -y apache2
sudo apt install -y apache2-bin
sudo apt install -y apache2-data
sudo apt install -y apache2-utils
sudo apt install -y libapache2-mod-php7.4
sudo apt install -y libcurl4
sudo apt install -y php7.4
sudo apt install -y php7.4-mysql
sudo apt install -y php7.4-common
sudo apt install -y php7.4-json
sudo apt install -y php7.4-opcache
sudo apt install -y php7.4-readline
sudo apt install -y php7.4-bz2
sudo apt install -y php7.4-cli
sudo apt install -y php7.4-curl
sudo apt install -y php7.4-gd
sudo apt install -y php7.4-mbstring
sudo apt install -y php7.4-xml
sudo apt install -y php7.4-bcmath
##
sudo apt install -y php7.4-mcrypt
sudo apt install -y php7.4-zip
#sudo apt install -y php-symfony-polyfill-php74
##
sudo apt install -y php-pear
sudo apt install -y php7.4-dev
sudo apt install -y libmcrypt-dev
sudo apt install -y gcc
sudo apt install -y make
sudo apt install -y autoconf
sudo apt install -y libc6-dev
sudo apt install -y pkg-config
sudo pecl update-channels
sudo pear update-channels
echo "\033[1;32m на ожидании ввода libmcrypt prefix - просто нажмите ENTER \033[0m"
# будет ожидать ввода libmcrypt prefix - просто нажать ENTER
sudo pecl install mcrypt-1.0.5
sudo apt install -y dbconfig-mysql
sudo apt install -y mariadb-common
sudo apt install -y mariadb-client
sudo apt install -y mariadb-server

sudo update-alternatives --set php /usr/bin/php7.4

### Устанавливаем phpMyAdmin
pma=https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.xz
DIR="/var/www/phpmyadmin"
if [ ! -d "$DIR" ]; then
# Создать папку, только если ее не было
sudo mkdir $DIR
fi
sudo wget $pma
sudo mkdir pma
sudo tar -C pma -xf phpMyAdmin-latest-all-languages.tar.xz --strip-components 1
sudo rm phpMyAdmin-latest-all-languages.tar.xz
sudo cp -rf pma/* $DIR
sudo rm -Rf ./pma
DIR1="/var/www/phpmyadmin/tmp"
if [ ! -d "$DIR1" ]; then
# Создать папку, только если ее не было
sudo mkdir $DIR1
sudo chmod 777 /var/www/phpmyadmin/tmp
fi

### Настраиваем PHP для Apache
echo "extension=mcrypt.so" | sudo tee -a /etc/php/7.4/apache2/conf.d/mcrypt.ini
sudo sed -i '/short_open_tag/s/Off/On/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/error_reporting/s/~E_DEPRECATED & ~E_STRICT/~E_NOTICE/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/max_execution_time/s/30/90/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/max_input_time/s/60/180/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/post_max_size/s/8/200/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/upload_max_filesize/s/2/50/' /etc/php/7.4/apache2/php.ini
sudo sed -i '/max_file_uploads/s/20/150/' /etc/php/7.4/apache2/php.ini
### Настраиваем PHP для коммандной строки
sudo sed -i '/short_open_tag/s/Off/On/' /etc/php/7.4/cli/php.ini

### Запрашиваем у пользователя пароль для MySQL
echo "\033[1;32m Настраиваем БД, введите пароль root MySQL \033[0m"
echo -n "Enter MySQL password > "
read pass
### MariaDB for Ubuntu 22
sudo systemctl stop mariadb
sudo systemctl set-environment MYSQLD_OPTS="--skip-grant-tables --skip-networking"
sudo systemctl start mariadb
sudo mysql -u root << EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '$pass';
flush privileges;
EOF
sudo systemctl unset-environment MYSQLD_OPTS
sudo systemctl restart mariadb

else
#####################################
### Для всех кроме Ubuntu22 ###
#
### симлинк для PHPMyAdmin
sudo ln -s /usr/share/phpmyadmin /var/www/phpmyadmin
### Запрашиваем у пользователя пароль для MySQL
echo "\033[1;32m Настраиваем БД, введите пароль root MySQL \033[0m"
echo -n "Enter MySQL password > "
read pass
### Настраиваем доступ root к MariaDB и устанавливаем начальные настройки интерфейса MajorDoMo 
mysql -u root << EOF
use mysql;
update user set password=PASSWORD("$pass") where User='root';
flush privileges;
update user set plugin='' where User='root';
EOF
sudo systemctl restart mariadb
fi

######################
### Общее для всех ###

### Настраиваем Apache
sudo sed -i 's/None/All/g' /etc/apache2/apache2.conf
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
sudo sed -i 's/\/html//' /etc/apache2/sites-available/000-default.conf
### Включаем мод rewrite для Apache
sudo a2enmod rewrite
### Обновляем и перезапускаем службы
sudo systemctl daemon-reload
sudo apache2ctl restart
sudo systemctl restart mariadb
### Скачиваем систему MajorDoMo с GitHab
cd /usr/src
sudo git clone https://github.com/akakisoni/MyMD.git
#unzip majordomo.zip

### Переносим систему в директорию WEB-сервера
sudo cp -rp /usr/src/majordomo/* /var/www
sudo cp -rp /usr/src/majordomo/.htaccess /var/www
### Создаем конфигурационный файл для системы
sudo cp /var/www/config.php.sample /var/www/config.php
### Назначаем права и владельца для директории с системой
sudo chown -R www-data:www-data /var/www
find /var/www/ -type f -exec sudo chmod 0666 {} \;
find /var/www/ -type d -exec sudo chmod 0777 {} \;
###Создаем описание сервиса для запуска основного цикла системы
sudo tee /etc/systemd/system/majordomo.service << EOF
[Unit]
Description=MajorDoMo
Requires=network.target mysql.service apache2.service
After=dhcpcd.service mysql.service apache2.service

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/bin/php /var/www/cycle.php
ExecStop=/usr/bin/pkill -f cycle_*

KillSignal=SIGKILL
KillMode=control-group
RestartSec=1min
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

######################
### Настраиваем БД ###
### Отключаем режим "Strict mode" для MySQL (для избавления от наследственных ошибок)
sudo tee /etc/mysql/conf.d/disable_strict_mode.cnf << EOF
[mysqld]
sql_mode=IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
EOF
sudo systemctl restart mariadb
### Создаём базу для MajorDoMo
# Настраиваем подключение к БД для системы
sudo sed -i "/DB_PASSWORD/s/''/'$pass'/" /var/www/config.php
# Создаем БД db_terminal и импортируем содержимое из дистрибутива
mysql -u root -p$pass << EOF
CREATE DATABASE db_terminal CHARACTER SET utf8 COLLATE utf8_general_ci;
EOF
mysql -u root -p$pass db_terminal < /var/www/db_terminal.sql
# Правим БД db_terminal
mysql -u root -p$pass << EOF
use db_terminal;
update pinghosts set HOSTNAME='ya.ru';
update settings set VALUE='dark' where NAME='THEME';
insert into settings (TITLE,NAME,TYPE,NOTES,VALUE,DEFAULTVALUE,DATA) VALUES ('Language','SITE_LANGUAGE','text','','ru','ru','');
insert into settings (TITLE,NAME,TYPE,NOTES,VALUE,DEFAULTVALUE,DATA) VALUES ('Time zone','SITE_TIMEZONE','text','','Europe/Moscow','Europe/Moscow','');
insert into settings (PRIORITY,TITLE,NAME,TYPE,NOTES,VALUE,DEFAULTVALUE,DATA) VALUES (30,'Before SAY (code)','HOOK_BEFORE_SAY','text','','','','');
EOF

### Добавляем главный цикл системы в автозагрузку
sudo systemctl enable majordomo
### Запускаем основной цикл
sudo systemctl start majordomo
### Обновляем систему
wget -q http://localhost/modules/saverestore/update_iframe.php
wget -q http://localhost/modules/market/update_iframe.php?mode2=update_all
find . -name '*update_iframe*' -delete
### Базовая система установлена
#cd /usr/src
#rm majordomo.zip
#rm majordomo

echo "\033[1;32m Базовая система установлена \033[0m"
echo "\033[1;32m Установить ситезатор голоса RHVoice (если нужно) - sh rhvoice.sh \033[0m"
echo "\033[1;32m Установить VLC (если нужно) - sh vlc.sh \033[0m"
echo "\033[1;32m Установить Mosquitto (если нужно) - sh mosquitto.sh \033[0m"
echo "\033[1;32m Перезагрузить компьютер (если нужно) - shutdown -r now \033[0m"
