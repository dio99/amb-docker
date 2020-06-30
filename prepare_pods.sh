#!/usr/bin/bash

SCRIPT=$(basename $0)
AMB_DOCKER_DIR=$(pwd)
if [ -f $AMB_DOCKER_DIR/$SCRIPT ];
then
        echo "Starting amb_docker prepare"
else
        echo "script needs to be executed from amb_docker dir"
        exit 1
fi

mkdir $AMB_DOCKER_DIR/mysql-datadir/ambweb
mkdir $AMB_DOCKER_DIR/mysql-datadir/karts
mkdir $AMB_DOCKER_DIR/AMBWEB_LOG

chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/mysql-datadir/ambweb
chcon -Rt svirt_sandbox_file_t $AMB_DOCKER_DIR/mysql-datadir/karts


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
ALLOWED_HOSTS = ['kart.mindruv.eu', '127.0.0.1']
DIRS = ['/code/ambweb/amb_web/races/templates']
LOGFILE = '/var/log/AMB/dajngo_debug.log'
ER_LOGFILE = '/var/log/AMB/dajngo_debug.log'
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
" >> $AMB_DOCKER_DIR/ambweb/ambweb/meta_settings.py

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


