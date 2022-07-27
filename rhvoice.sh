#!/bin/bash
# Codepage UTF-8

pause=2

### Обновляем информацию о репозиториях
sudo apt update
### Устанавливаем необходимые пакеты
sudo apt install -y mplayer
sudo apt install -y alsa-base
sudo apt install -y alsa-utils
sudo apt install -y alsa-tools
sudo apt install -y libao4
sudo apt install -y libao-common
sudo apt install -y libao-dev
sudo apt install -y pulseaudio

### Изменяем настройки PulseAudio для устранения заиканий
sudo tee -a /etc/pulse/daemon.conf << EOF
high-priority = no
nice-level = -1
realtime-scheduling = yes
realtime-priority = 5
flat-volumes = no
resample-method = speex-float-1
default-sample-rate = 48000
default-fragments = 4
default-fragment-size-msec = 25
EOF

### Добавляем пользователя www-data в группу audio
sudo usermod -a -G audio www-data

#############################
### Устанавливаем RHVoice ###

### Проверка версии Ubuntu \ Mint, их разрядности
echo "\033[1;32m Определяю версию Ubuntu \033[0m"
ubnt=$(cat /etc/issue.net)
ubnt1=$(uname -a)

#######################
### Ubuntu 16 \ x32 ###
if echo $ubnt | grep -q -s -F "Ubuntu 16" || echo $ubnt1 | grep -q -s -F "i686"; then
echo "\033[1;32m Ubuntu 16 или разрядность x32 ставим RHVoice без компиляции.\033[0m"
$pause
sudo apt install software-properties-common
sudo add-apt-repository -y ppa:linvinus/rhvoice
sudo apt update
sudo apt install -y rhvoice rhvoice-russian
sudo apt install -y speech-dispatcher-rhvoice
fi

#####################################
### Ubuntu 18,20,22 \  Mint 19,20 ###
echo "\033[1;32m $ubnt x64, компилируем RHVoice из исходников.\033[0m"
$pause
sudo apt install -y gcc
sudo apt install -y g++
sudo apt install -y git
sudo apt install -y pkg-config
sudo apt install -y scons
sudo apt install -y python-lxml
sudo apt install -y libpulse-dev
sudo apt install -y portaudio19-dev
sudo apt install -y speech-dispatcher
sudo apt install -y libspeechd-dev

cd /usr/src
sudo git clone --recursive https://github.com/Olga-Yakovleva/RHVoice
cd RHVoice
sudo scons
sudo scons install
sudo ldconfig

### RHVoice установлен
echo "\033[1;32m Синтезатор голоса RHVoice установлен \033[0m"
echo "\033[1;32m Установить VLC (если нужно) - sh vlc.sh \033[0m"
echo "\033[1;32m Установить Mosquitto (если нужно) - sh mosquitto.sh \033[0m"
echo "\033[1;32m Перезагрузить компьютер (если нужно) - shutdown -r now \033[0m"
