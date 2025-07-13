#!/usr/bin/env bash
set -euo pipefail

# 1. Обновление и базовые утилиты
echo "1. Обновление системы и установка утилит..."
apt update -y && apt full-upgrade -y
apt install -y unzip net-tools git curl locales-all

# 2. Локаль
echo "2. Настройка локали ru_RU.UTF-8..."
locale-gen ru_RU.UTF-8
update-locale LANG=ru_RU.UTF-8

# 3. Отключаем брандмауэр и спящий режим
echo "3. Отключение UFW и спящих целей..."
systemctl disable --now ufw || true
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# 4. Apache + PHP 8.2
echo "4. Установка Apache и PHP 8.2..."
apt install -y apache2 libapache2-mod-php8.2 \
    php8.2 php8.2-cli php8.2-common php8.2-mysql \
    php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml \
    php8.2-bcmath php-pear php8.2-dev
# Настройка Apache
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
echo "ServerName localhost" >> /etc/apache2/apache2.conf
a2enmod rewrite
systemctl reload apache2

# 5. MariaDB
echo "5. Установка и настройка MariaDB..."
apt install -y mariadb-server mariadb-client
systemctl enable --now mariadb

MYSQL_ROOT_PWD="ВашRootПароль"
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PWD}'; FLUSH PRIVILEGES;" \
    | mysql -u root

# 6. Создаём БД majordomo и пользователя
echo "6. Создание БД и пользователя majordomo..."
mysql -u root -p"${MYSQL_ROOT_PWD}" <<SQL
CREATE DATABASE majordomo CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'majordomo'@'localhost' IDENTIFIED BY 'MD_Pass123';
GRANT ALL PRIVILEGES ON majordomo.* TO 'majordomo'@'localhost';
FLUSH PRIVILEGES;
SQL

# 7. Загрузка и распаковка MajorDoMo
echo "7. Загрузка MajorDoMo и распаковка..."
cd /usr/src
rm -rf majordomo-src majordomo
git clone https://github.com/akakisoni/MyMD.git majordomo-src
unzip -q majordomo-src/mjdm.zip -d majordomo

# 8. Определяем, откуда копировать
echo "8. Определяем исходную папку для копирования..."
if [ -d majordomo/majordomo ]; then
  SRC="majordomo/majordomo"
else
  SRC="majordomo"
fi
echo "  Копируем из: \$SRC = $SRC"

# 9. Копируем файлы в веб-директорию
echo "9. Копируем файлы в /var/www/html/ ..."
cp -rp "$SRC"/* /var/www/html/

# 10. Копируем .htaccess, если он есть
if [ -f "$SRC/.htaccess" ]; then
  echo "10. Копируем .htaccess ..."
  cp "$SRC/.htaccess" /var/www/html/
else
  echo "10. .htaccess не найден, пропускаем."
fi

# 11. Права доступа
echo "11. Устанавливаем права доступа..."
chown -R www-data:www-data /var/www/html/
find /var/www/html/ -type f -exec chmod 0666 {} \;
find /var/www/html/ -type d -exec chmod 0777 {} \;

# 12. systemd-сервис majordomo
echo "12. Создание и запуск systemd-сервиса majordomo..."
cat > /etc/systemd/system/majordomo.service <<EOF
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

systemctl daemon-reload
systemctl enable --now majordomo

echo "=== Установка MajorDoMo завершена ==="
echo "Откройте в браузере: http://<IP_вашего_сервера>/ для финальной настройки."
