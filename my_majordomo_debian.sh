#!/usr/bin/env bash
set -e

# 1. Обновление системы
echo "Обновляем пакеты..."
sudo apt update -y && sudo apt full-upgrade -y

# 2. Установка утилит и локали
echo "Устанавливаем базовые пакеты..."
sudo apt install -y unzip net-tools git curl locales-all
echo "Настраиваем локаль ru_RU.UTF-8..."
sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8

# 3. Отключаем брандмауэр UFW и спящие режимы
echo "Отключаем UFW и спящий режим..."
sudo systemctl disable --now ufw || true
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 4. Установка Apache и PHP 8.2
echo "Устанавливаем Apache и PHP..."
sudo apt install -y apache2 libapache2-mod-php8.2 \
    php8.2 php8.2-cli php8.2-common php8.2-mysql \
    php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml \
    php8.2-bcmath php-pear php8.2-dev

# Настройка Apache
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

# 5. Установка MariaDB
echo "Устанавливаем MariaDB..."
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable --now mariadb

# 6. Секьюризация и установка пароля root
MYSQL_ROOT_PWD="ВашRootПароль"
echo "Настраиваем пароль для root@localhost..."
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PWD'; FLUSH PRIVILEGES;"

# 7. Создание БД и пользователя для MajorDoMo
echo "Создаём БД majordomo и пользователя majordomo..."
sudo mysql -uroot -p"$MYSQL_ROOT_PWD" <<SQL
CREATE DATABASE majordomo CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'majordomo'@'localhost' IDENTIFIED BY 'MD_Pass123';
GRANT ALL PRIVILEGES ON majordomo.* TO 'majordomo'@'localhost';
FLUSH PRIVILEGES;
SQL

# 8. Развёртывание MajorDoMo
echo "Загружаем MajorDoMo..."
cd /usr/src
sudo git clone https://github.com/akakisoni/MyMD.git majordomo-src
sudo unzip majordomo-src/mjdm.zip -d majordomo
sudo cp -rp majordomo/* /var/www/html/
sudo cp -rp majordomo/.htaccess /var/www/html/

# 9. Права доступа
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type f -exec chmod 0666 {} \;
sudo find /var/www/html/ -type d -exec chmod 0777 {} \;

# 10. Systemd-служба MajorDoMo
echo "Создаём сервис majordomo.service..."
sudo tee /etc/systemd/system/majordomo.service > /dev/null <<EOF
[Unit]
Description=MajorDoMo Home Automation
After=network.target mariadb.service apache2.service

[Service]
Type=simple
User=www-data
Group=www-data
ExecStart=/usr/bin/php /var/www/html/cycle.php
Restart=on-failure
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now majordomo

echo "Установка MajorDoMo на Debian 12 завершена!"
