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

mkdir ./mysql-datadir

# create .env file 

vim .env_db

2) ambweb

configure - ambweb/meta_settings.py




======= notes =========

# any cahnge to .env_db should be ignored
git update-index --skip-worktree .env_db
