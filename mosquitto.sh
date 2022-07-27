#!/bin/bash
# Codepage UTF-8

#####################################
### Запрашиваем вариант установки ###
echo "\033[0;33m Выберите вариант установки Mosquitto \033[0m"
echo "\033[0;33m 1 - с анонимным доступом \033[0m"
echo "\033[0;33m 2 - с авторизацией по логину и паролю \033[0m"
echo -n "\033[0;32m Введите номер варианта > \033[0m"
read var

#########################
### Базовая установка ###
### Добавляем официальный репозиторий
apt-add-repository -y ppa:mosquitto-dev/mosquitto-ppa
apt update

### Ставим mosquitto
apt install -y mosquitto
systemctl stop mosquitto

### Переименовываем конфиг по-умолчанию
mv /etc/mosquitto/mosquitto.conf /etc/mosquitto/mosquitto.conf.bak

### Создаем новый конфиг по-умолчанию
touch /etc/mosquitto/mosquitto.conf
cat <<EOF >> /etc/mosquitto/mosquitto.conf
# Place your local configuration in /etc/mosquitto/conf.d/
#
# A full description of the configuration file is at
# /usr/share/doc/mosquitto/examples/mosquitto.conf.example

include_dir /etc/mosquitto/conf.d

EOF

### Создаем рабочий конфиг
touch /etc/mosquitto/conf.d/main.conf
cat <<EOF >> /etc/mosquitto/conf.d/main.conf
# =================================================================
# =================================================================
# General configuration
# =================================================================
#socket_domain ipv4
retain_available true
#retained_persistence true
#autosave_interval 1800

pid_file /var/run/mosquitto/mosquitto.pid
#pid_file /etc/mosquitto/mosquitto.pid

#keepalive_interval 3600
#persistent_client_expiration 2m

# =================================================================
# Default listener
# =================================================================

# порт по умолчанию 1883, при необходимости можно задать другой
listener 1883

# =================================================================
# Persistence
# =================================================================

persistence true
persistence_file mosquitto.db
persistence_location /etc/mosquitto/

# =================================================================
# Logging
# =================================================================

#log_timestamp true
log_timestamp_format %Y.%m.%d (%H:%M:%S)
log_dest syslog
log_facility 5

# на время установки\запуска\отладки да и вообще удобно иметь перед глазами, радом с конфигами
log_dest file /etc/mosquitto/mosquitto.log
#log_dest file /var/log/mosquitto/mosquitto.log

#log_type debug
log_type error
#log_type warning
#log_type notice
#log_type information

EOF

########################
### Анонимный доступ ###
if [ $var = "1" ]; then

### Правим конфиг для анонимного доступа
cat <<EOF >> /etc/mosquitto/conf.d/main.conf
# =================================================================
# Authentication and topic access control
# =================================================================

allow_anonymous true
#password_file /etc/mosquitto/users.list
#acl_file /etc/mosquitto/mosquitto.acl

# =================================================================

EOF
fi

#############################
### Доступ с авторизацией ###
if [ $var = "2" ]; then 

### Правим конфиг для доступа с атворизацией
cat <<EOF >> /etc/mosquitto/conf.d/main.conf
# =================================================================
# Authentication and topic access control
# =================================================================

#allow_anonymous true
password_file /etc/mosquitto/users.list
acl_file /etc/mosquitto/mosquitto.acl

# =================================================================

EOF

### Создаём конфиг моста к другому брокеру
touch /etc/mosquitto/bridge.conf
cat <<EOF >> /etc/mosquitto/bridge.conf
# =================================================================
# Bridge
# =================================================================

connection connection-name
#address xxx.xxx.xxx.xxx:port
address xxx.xxx.xxx.xxx
try_private false
notifications false
start_type automatic
remote_username username
remote_password password

topic # both
#topic # in
#topic # out

# =================================================================

EOF

### Создаём памятку
touch /etc/mosquitto/README
cat <<EOF >> /etc/mosquitto/README

1. учётные записи
- содержатся (вместе с зашифрованными паролями) в файле /etc/mosquitto/users.list
- для добавления пользователя используйте команду в командной строке (PuTTY): 
mosquitto_passwd /etc/mosquitto/users.list username

https://mosquitto.org/man/mosquitto_passwd-1.html

2. доступ к топикам
- описывается в файле /etc/mosquitto/mosquitto.acl
редактируем любимым текстовым редактором, или например открыв файл через WinSCP
пример сдержимого: 

user test
topic readwrite #

EOF

######################
### Учётные записи ###
### Запрашиваем имя пользователя
echo "\033[1;32m Введите имя пользователя, затем пароль и подтвердите пароль \033[0m"
echo -n " Enter username > "
read user

### Создаём учётную запись пользователя mosquitto
touch /etc/mosquitto/users.list
mosquitto_passwd /etc/mosquitto/users.list $user

### Создаём файл прав доступа пользователей к топикам
touch /etc/mosquitto/mosquitto.acl
cat <<EOF >> /etc/mosquitto/mosquitto.acl
user $user
topic readwrite #

EOF
fi

######################
### Общее для всех ###
### Назначаем права и запускаем mosquitto
chmod -R 755 /etc/mosquitto
chown -R mosquitto /etc/mosquitto
systemctl start mosquitto

### ГОТОВО
echo "\033[1;32m ГОТОВО \033[0m"
