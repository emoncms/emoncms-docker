# Install Docker & docker-compose

- Docker install docs 
- Docker Compose install docs 


## Start / Stop docker container 

### Start as an incidence: 

`$ docker-compose up`

This will start two containers `emon_web` which is based on the official docker [PHP-Apache image](https://hub.docker.com/_/php/) and `emon_db` which is based on the official docker [MYSQL image](https://hub.docker.com/_/mysql). 

`emon_db` MYSQL database will be connected to `emon_web` via internal docker port `3303`, the database is not exposed to any external host port. 

`emon_web` php-apache container will expose its port `80` on host port `8080`. To run Emoncms bring up the containers using docker-compose then browse to: 

[https://localhost:8080](https://localhost:8080) 

`[Ctrl + C]]` to kill

### Run as a daemon service (in the background)

`$ docker-compose up -d`

To stop container(s) if running as service:

List running containers:

`$ docker ps`

`$ docker stop XXX`

or

`$ docker kill XXX`

Where XX is container id or name

## Build docker container 

Required if `Dockerfile` or `Docker-compose.yml` are changed. 

`$ docker-compose build`

## useful Docker commands

Stop / kill all running containers:

`$ docker stop $(docker ps -a -q)`

`$ docker kill $(docker ps -a -q)`

Remove all containers:

e.g. emon_web, emon_db

`docker rm $(docker ps -a -q)`

Remove all images:

e.g. Base php-apache, mysql, Ubuntu pulled from Dockerhub

` $ docker rmi $(docker images -q)`