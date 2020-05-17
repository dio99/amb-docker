# amb-docker
Containerized environment for ambweb/ambp3cilent

## Usage

Clone this repository and run:

```
git submodule init; git submodule update
docker-compose up --build -d
```


======= setup ==============


1) DB

# create MySQL data dir

mkdir -p ./mysql-datadir/ambweb
mkdir -p ./mysql-datadir/karts

# create .env file 

cp .env_db.example .env_karts_db
cp .env_db.example .env_ambweb_db

2) ambweb

configure - ambweb/meta_settings.py
mkdir ./AMBWEB_LOG



3) amb_laps

cp conf.yaml local_conf.yaml
vim local_conf.yaml # update missing options





======== restore =================

```
mysql -P 3307 -p -h 127.0.0.1 karts < ambp3client/schema
```


======= notes =========

# any cahnge to .env_db should be ignored
git update-index --skip-worktree .env_db
