#!/usr/bin/bash

if [ -f .install_lock ]
then
    echo "FOUND: .install_lock will not install"
    echo "run setup manually"
else
    #$ROOT_DIR='/opt/amb-docker/'
    ROOT_DIR='/home/vmindru/proj/amb-docker/'
    
    mkdir -p mysql-datadir/ambweb
    mkdir -p mysql-datadir/karts
    mkdir AMBWEB_LOG
    mkdir AMB_CLIENT_LOGS
    mkdir AMB_LAPS_LOGS
    mkdir chcon -Rt svirt_sandbox_file_t AMB_TEST_SERVER
    
    chcon -Rt svirt_sandbox_file_t $ROOT_DIR/mysql-datadir/karts/
    chcon -Rt svirt_sandbox_file_t $ROOT_DIR/mysql-datadir/ambweb/
    chcon -Rt svirt_sandbox_file_t $ROOT_DIR/mysql-config/karts/
    chcon -Rt svirt_sandbox_file_t $ROOT_DIR/AMB_CLIENT_LOGS/
    chcon -Rt svirt_sandbox_file_t $ROOT_DIR/AMB_LAPS_LOGS/
    chcon -Rt svirt_sandbox_file_t $ROOT_DIR/AMBWEB_LOG
    
    
    DB_ROOT_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    
    AMBWEB_DB_PORT='3306'
    AMBWEB_DB_USER='ambweb'
    AMBWEB_DB_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    AMBWEB_DB='ambweb'
    AMBWEB_DB_HOST='ambweb_db'
    AMBWEB_RANDOM_SECRET=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)
    
    KARTS_DB_PWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 24 | head -n 1)
    KARTS_DB_USER='karts'
    KARTS_DB='karts'
    KARTS_DB_PORT='3307'
    KARTS_DB_HOST='karts_db'
    
    
    AMB_DECODER_IP='127.0.0.1'
    AMB_DECODER_PORT='5403' # DEFAULT 5403
    
    echo "UPDATING: ambweb/ambweb/meta_settings.py"
    echo "import os
DEBUG = True
SECRET_KEY = '$AMBWEB_RANDOM_SECRET'
DATABASES = {
    'default': {
      'ENGINE': 'django.db.backends.mysql',
      'NAME': '$AMBWEB_DB',
      'USER': '$AMBWEB_DB_USER',
      'PASSWORD': '$KARTS_DB_PWD',
      'HOST': '$AMBWEB_DB_HOST',
      'PORT': '$AMBWEB_DB_PORT',
    },
    'kartsdb': {
            'ENGINE': 'django.db.backends.mysql',
            'NAME': 'karts',
            'USER': 'karts',
            'PASSWORD': 'CHANGEME',
            'HOST': 'db',
            'PORT': '3311',
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
    
    
    echo "UPDATE: .env_karts_db"
    echo "MYSQL_ROOT_PASSWORD=$DB_ROOT_PWD
MYSQL_USER=$KARTS_DB_USER
MYSQL_PASSWORD=$KARTS_DB_PWD
MYSQL_DATABASE=$KARTS_DB
MYSQL_PORT=$KARTS_DB_PORT
" > .env_karts_db
    
    echo "UPDATE: .env_ambweb_db"
    echo "MYSQL_ROOT_PASSWORD=$DB_ROOT_PWD
MYSQL_USER=$AMBWEB_DB_USER
MYSQL_PASSWORD=$AMBWEB_DB_PWD
MYSQL_DATABASE=$AMBWEB_DB
MYSQL_PORT=$AMBWEB_DB_PORT
" > .env_ambweb_db
    
    touch $ROOT_DIR/.install_lock
    
fi

echo "podman-compose up --build -d"
echo "#podman ps #check containers" 
echo "restore DB: podman exec -i  amb-docker_karts_db_1 sh -c 'mysql -u root -pPASSWORD karts' < ./ambp3client/schema"


