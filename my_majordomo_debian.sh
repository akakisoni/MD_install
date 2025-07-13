#!/usr/bin/env bash
set -e

# 1. Подготовка системы
echo "Обновляем пакеты..."
sudo apt update -y && sudo apt full-upgrade -y

# 2. Установка базовых утилит
echo "Устанавливаем утилиты..."
sudo apt install -y unzip net-tools git curl locales-all

# 3. Настройка русской локали
echo "Настраиваем локаль ru_RU.UTF-8..."
sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8

# 4. Отключаем UFW
echo "Отключаем UFW..."
sudo systemctl disable --now ufw || true

# 5. Отключаем спящие режимы
echo "Отключаем спящий режим..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 6. Установка Apache и PHP 8.2
echo "Устанавливаем Apache и PHP 8.2..."
sudo apt install -y apache2 libapache2-mod-php8.2 \
    php8.2 php8.2-cli php8.2-common php8.2-mysql \
    php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml \
    php8.2-bcmath php-pear php8.2-dev

# 7. Настройка Apache
echo "Настраиваем Apache..."
sudo sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
echo "ServerName localhost" | sudo tee -a /etc/apache2/apache2.conf
sudo a2enmod rewrite
sudo systemctl reload apache2

# 8. Установка MariaDB
echo "Устанавливаем MariaDB..."
sudo apt install -y mariadb-server mariadb-client
sudo systemctl enable --now mariadb

# 9. Секьюризация MariaDB
echo "Настраиваем root-пароль MariaDB..."
MYSQL_ROOT_PWD="ВашRootПароль"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$MYSQL_ROOT_PWD'; FLUSH PRIVILEGES;"

# 10. Создание базы и пользователя для MajorDoMo
echo "Создаём БД majordomo и пользователя..."
sudo mysql -uroot -p"$MYSQL_ROOT_PWD" <<SQL
CREATE DATABASE majordomo CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'majordomo'@'localhost' IDENTIFIED BY 'MD_Pass123';
GRANT ALL PRIVILEGES ON majordomo.* TO 'majordomo'@'localhost';
FLUSH PRIVILEGES;
SQL

# 11. Загрузка и развёртывание MajorDoMo
echo "Загружаем MajorDoMo..."
cd /usr/src
sudo git clone https://github.com/akakisoni/MyMD.git majordomo-src
sudo unzip majordomo-src/mjdm.zip -d majordomo
sudo cp -rp majordomo/* /var/www/html/
sudo cp -rp majordomo/.htaccess /var/www/html/

# 12. Настройка прав
echo "Устанавливаем права..."
sudo chown -R www-data:www-data /var/www/html/
sudo find /var/www/html/ -type f -exec chmod 0666 {} \;
sudo find /var/www/html/ -type d -exec chmod 0777 {} \;

# 13. Создание systemd-сервиса
echo "Создаём majordomo.service..."
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

# 14. Включение и запуск сервиса
echo "Включаем и стартуем majordomo..."
sudo systemctl daemon-reload
sudo systemctl enable --now majordomo

echo "Установка MajorDoMo на Debian 12 завершена!"
