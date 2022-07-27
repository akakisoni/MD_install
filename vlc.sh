#!/bin/bash
# Codepage UTF-8

#проверка версии Ubuntu\Mint и установка пакетов
#echo "\033[1;32m определяю версию Ubuntu \033[0m"
ubnt=$(cat /etc/issue.net)

# Обновляем информацию о репозиториях
sudo apt update
# Устанавливаем необходимые пакеты
sudo apt install -y mpd
sudo apt install -y mplayer
sudo apt install -y ffmpeg

# для Ubuntu 20\22 ставим VLC без выебонов
if echo $ubnt | grep -q -s -F "Ubuntu 20" || echo $ubnt | grep -q -s -F "Ubuntu 22"; then
sudo apt install --no-install-recommends -y vlc
fi

sudo apt install -y vlc

# Создаем описание сервиса VLC на порту 8080 с паролем "password" (имя пользователя - пустое поле)
sudo tee /etc/systemd/system/vlcd.service << EOF
[Unit]
Description=VLCDaemon
Requires=majordomo.service

[Service]
Type=simple
WorkingDirectory=/var/www
ExecStart=/usr/bin/vlc -I http --http-password=password
Restart=always
User=www-data
Group=www-data
[Install]
WantedBy=multi-user.target
EOF
# Обновляем и Добавляем vlc в автозагрузку
sudo systemctl daemon-reload
sudo systemctl enable vlcd
sudo systemctl start vlcd
# VLC установлен
echo "\033[1;32m VLC установлен \033[0m"
echo "\033[1;32m Установить Mosquitto (если нужно) - sh mosquitto.sh \033[0m"
echo "\033[1;32m Перезагрузить компьютер (если нужно) - shutdown -r now \033[0m"
