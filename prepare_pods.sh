#!/usr/bin/bash

mkdir mysql-datadir/ambweb
mkdir mysql-datadir/karts
mkdir AMBWEB_LOG

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
ALLOWED_HOSTS = ['kart.mindruv.eu', '127.0.0.1',]
DIRS = ['/home/vmindru/proj/amb/amb_web/races/templates']
LOGFILE = '/var/log/AMB/dajngo_debug.log'
ER_LOGFILE = '/var/log/AMB/dajngo_debug.log'
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
" >> ambweb/ambweb/meta_settings.py

cp ambp3client/conf.yaml ambp3client/local_conf.yaml

echo -n "##########################################################################\n"
echo "SETUP FINISHED, DON'T FORGET TO:"
echo "UPDATE: .env_karts_db"
echo "UPDATE: .env_ambweb_db"
echo "CHECK: ambp3client/local_conf.yaml"
echo "CHECK: ambweb/ambweb/meta_settings.py"
echo "EXEC: podman-compose up --build -d"
echo "EXEC: podman ps #check containers"
echo "RESTORE DB: podman exec -i  amb-docker_karts_db_1 sh -c 'mysql -u root -pPASSWORD karts' < ./ambp3client/schema"

