#!/usr/bin/bash


export PALETTE_RED='\e[31m'
export PALETTE_RESET='\e[0m'
export PALETTE_BOLD='\e[1m'
export PALETTE_PURPLE='\e[35m'
export PALETTE_GREEN='\e[32m'
export PALETTE_YELLOW='\e[33m'
export DEFAULT_IP=127.0.0.1


SCRIPT=$(basename $0)
AMB_DOCKER_DIR=$(pwd)
if [ -f $AMB_DOCKER_DIR/$SCRIPT ];
then
        echo -e "${PALETTE_YELLOW}Running${PALETTE_RESET} amb_docker prepare"
else
        echo -e "${PALETTE_RED}ERROR:${PALETTE_RESET} script needs to be executed from amb_docker dir"
        exit 1
fi


if [ -f $AMB_DOCKER_DIR/.install_lock ]
then
    echo -e "${PALETTE_PURPLE}FOUND:${PALETTE_RESET} .install_lock, skiping configs install"
else
    [ -d  mysql-datadir/ambweb ] ||  mkdir -p mysql-datadir/ambweb
    [ -d  mysql-datadir/ambweb ] ||  mkdir -p mysql-datadir/karts
    [ -d AMBWEB_LOG ] ||  mkdir AMBWEB_LOG
    [ -d AMB_CLIENT_LOGS ] ||  mkdir AMB_CLIENT_LOGS
    [ -d AMB_LAPS_LOGS ] ||  mkdir AMB_LAPS_LOGS
    [ -d AMB_TEST_SERVER ] ||  mkdir AMB_TEST_SERVER

    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/AMB_TEST_SERVER
    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/mysql-datadir/karts/
    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/mysql-datadir/ambweb/
    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/mysql-config/karts/
    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/AMB_CLIENT_LOGS/
    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/AMB_LAPS_LOGS/
    chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/AMBWEB_LOG

    read -p "AMB_DECODER_IP: " AMB_DECODER_IP
    read -p "AMBWEB_DB_LISTEN_IP: " AMBWEB_DB_LISTEN_IP
    read -p "KARTS_DB_LISTEN_IP: " KARTS_DB_LISTEN_IP

    KARTS_DB_LISTEN_IP=${KARTS_DB_LISTEN_IP:-$DEFAULT_IP}
    AMBWEB_DB_LISTEN_IP=${AMBWEB_DB_LISTEN_IP:-$DEFAULT_IP}
    KARTS_DB_LISTEN_IP=${KARTS_DB_LISTEN_IP:-$DEFAULT_IP}

    export KARTS_DB_LISTEN_IP
    export AMBWEB_DB_LISTEN_IP
    export KARTS_DB_LISTEN_IP
    export AMB_DECODER_PORT='5403' # DEFAULT 5403


    export DB_ROOT_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    export AMBWEB_PORT="80${RANDOM:0:2}"

    export AMBWEB_DB_PORT="33${RANDOM:0:2}"
    export AMBWEB_DB_USER='ambweb'
    export AMBWEB_DB_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    export AMBWEB_DB='ambweb'
    export AMBWEB_DB_HOST=$AMBWEB_DB_LISTEN_IP
    export AMBWEB_RANDOM_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)

    export KARTS_DB_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    export KARTS_DB_USER='karts'
    export KARTS_DB='karts'
    export KARTS_DB_PORT="33${RANDOM:0:2}"
    export KARTS_DB_HOST=$KARTS_DB_LISTEN_IP



    echo "UPDATING: ambweb/ambweb/meta_settings.py"
    echo "import os
DEBUG = True
SECRET_KEY = '$AMBWEB_RANDOM_SECRET'
DATABASES = {
    'default': {
      'ENGINE': 'django.db.backends.mysql',
      'NAME': '$AMBWEB_DB',
      'USER': '$AMBWEB_DB_USER',
      'PASSWORD': '$AMBWEB_DB_PWD',
      'HOST': '$AMBWEB_DB_LISTEN_IP',
      'PORT': '$AMBWEB_DB_PORT',
    },
    'kartsdb': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': '$KARTS_DB',
            'USER': '$KARTS_DB_USER',
            'PASSWORD': '$KARTS_DB_PWD',
            'HOST': '$KARTS_DB_LISTEN_IP',
            'PORT': '$KARTS_DB_PORT',
        }
}
ALLOWED_HOSTS = ['kart.mindruv.eu', '127.0.0.1']
DIRS = ['/code/races/templates']
LOGFILE = '/var/log/AMB/dajngo_debug.log'
ER_LOGFILE = '/var/log/AMB/dajngo_debug.log'
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
" > ambweb/ambweb/meta_settings.py

    echo "UPDATING: ambp3client/local_conf.yaml"
    echo "---
ip: '$AMB_DECODER_IP'
port: $AMB_DECODER_PORT
file: "/tmp/out.log"
debug_file: "/tmp/amb_raw.log"
mysql_backend: True
mysql_db: '$KARTS_DB'
mysql_user: '$KARTS_DB_USER'
mysql_password: '$KARTS_DB_PWD'
mysql_port: $KARTS_DB_PORT
mysql_host: '$KARTS_DB_HOST'
    " > ambp3client/local_conf.yaml


    echo "UPDATING: .env_karts_db"
    echo "MYSQL_ROOT_PASSWORD=$DB_ROOT_PWD
MYSQL_USER=$KARTS_DB_USER
MYSQL_PASSWORD=$KARTS_DB_PWD
MYSQL_DATABASE=$KARTS_DB
MYSQL_PORT=$KARTS_DB_PORT
KARTS_MYSQL_PORT=$KARTS_DB_PORT
" > .env_karts_db

    echo "UPDATING: .env_ambweb_db"
    echo "MYSQL_ROOT_PASSWORD=$DB_ROOT_PWD
MYSQL_USER=$AMBWEB_DB_USER
MYSQL_PASSWORD=$AMBWEB_DB_PWD
MYSQL_DATABASE=$AMBWEB_DB
MYSQL_PORT=$AMBWEB_DB_PORT
AMBWEB_MYSQL_PORT=$AMBWEB_DB_PORT
" > .env_ambweb_db

    echo "AMBWEB_MYSQL_PORT=$AMBWEB_DB_PORT
AMBWEB_DB_LISTEN_IP=$AMBWEB_DB_LISTEN_IP
KARTS_DB_LISTEN_IP=$KARTS_DB_LISTEN_IP
KARTS_MYSQL_PORT=$KARTS_DB_PORT
AMBWEB_PORT=$AMBWEB_PORT" > .env

    touch $AMB_DOCKER_DIR/.install_lock

fi

echo -e "${PALETTE_GREEN}###########################################
###########################################
#######  PREPARE FINISHED NOW RUN  ########
###########################################
###########################################${PALETTE_RESET}"

echo "running podman build"
podman-compose down
podman-compose up --build -d


echo "restore DB: podman exec -i  amb-docker_karts_db_1 sh -c 'mysql -u root -pPASSWORD karts' < ./ambp3client/schema"



