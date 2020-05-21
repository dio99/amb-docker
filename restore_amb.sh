#!/usr/bin/bash

mkdir mysql-datadir/ambweb
mkdir mysql-datadir/karts
mkdir AMBWEB_LOG
mkdir AMB_CLIENT_LOGS
mkdir AMB_LAPS_LOGS

chcon -Rt svirt_sandbox_file_t /opt/amb-docker/mysql-datadir/karts/
chcon -Rt svirt_sandbox_file_t /opt/amb-docker/mysql-datadir/ambweb/


echo "
import os
DEBUG = True
SECRET_KEY = 'CHANGEME-BIG-RANDOM-SECRET'
DATABASES = {
    'default': {
      'ENGINE': 'django.db.backends.mysql',
      'NAME': 'ambweb',
      'USER': 'ambweb',
      'PASSWORD': 'CHANGEME',
      'HOST': 'db',
      'PORT': '3310',
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
ALLOWED_HOSTS = ['kart.mindruv.eu', '127.0.0.1', 'lsv-vm107.rfiserve.net']
DIRS = ['/home/vmindru/proj/amb/amb_web/races/templates']
LOGFILE = '/var/log/AMB/dajngo_debug.log'
ER_LOGFILE = '/var/log/AMB/dajngo_debug.log'
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
" >> ambweb/ambweb/meta_settings.py

cp ambp3client/conf.yaml ambp3client/local_conf.yaml
echo "UPDATE: .env_karts_db"
echo "UPDATE: .env_ambweb_db"
echo "UPDATE: ambp3client/local_conf.yaml, check ambweb/ambweb/meta_settings.py"
echo "podman-compose up --build -d"
echo "#podman ps #check containers" 
echo "restore DB: podman exec -i  amb-docker_karts_db_1 sh -c 'mysql -u root -pPASSWORD karts' < ./ambp3client/schema"
