# In Development

**NOT READY FOR USE**

***

# Install Docker

- [Offical Docker install guide](https://docs.docker.com/engine/installation/)

If running Linux Docker-compose will also need to be installed separately. Docker-toolbox on Mac and Windows includes Docker-compose

- [Offical Docker Compose install guide](https://docs.docker.com/compose/install/)

If running on Linux highly recomended to create Docker group to avoid having to use `sudo` with Docker commands:

```
$ sudo groupadd docker
$ sudo usermod -aG docker <YOUR-USER-NAME>
$ docker run hello-world
```

You should now be able to `docker run hello-world` without `sudo`.

## Use Docker image

*Pull emoncms image from docker hub (yet to be pushed)*

Pulling the emoncms image from docker up is the easiest way to fire up emoncms for production* or testing. For development you will probably want to build the image yourself to have full control.

\* **Docker image is currently in early testing and is NOT yet recommended for production**

##

## Build Emoncms Docker

For development.

#### Git Clone

clone emoncms-docker (this repo) and emoncms core:

	$ git clone https://github.com/emoncms/emoncms-docker

Inside emoncms-docker clone emoncms-core:

	$ cd emoncms-docker
	$ git clone https://github.com/emoncms/emoncms

Clone in optional modules (graph and dashboard are highly recommended):

	$ git clone https://github.com/emoncms/dashboard emoncms/Modules/dashboard
    $ git clone https://github.com/emoncms/graph emoncms/Modules/graph

*Further modules can be found in the [emoncms git repo](https://github.com/emoncms/) e.g. backup, wifi etc.*
 
File structure should look like:

```
+-- emoncms-docker
¦   +-- Dockerfile
¦   +-- docker-compose.yml
+-- emoncms
¦   +-- <emoncms-core files>
¦   +-- e.g index.php
¦   +-- Modules
¦       +-- <core-modules> e.g. admin, feed, input
¦       +-- <optional-modules> e.g dashboard
```



### Build / update Docker container

Required on first run or if `Dockerfile` or `Docker-compose.yml` are changed:

	$ docker-compose build


#### Start Emoncms containers

Start as foreground service:

	$ docker-compose up

Stop with [CTRL + c)

Start as background service:

	$ docker-compose up -d

This will start two containers `emon_web` which is based on the official docker [PHP-Apache image](https://hub.docker.com/_/php

***

# Docker Compose Setup

## Development Vs Production

There are three docker compose files:

1. `docker-compose.yml`
2. `docker-compose.override.yml`
3. `docker-compose.prod.yml`

The first `docker-compose.yml` sets up the base config, things that are common to both development and production.

The second file `docker-compose.override.yml` sets up the development enviroment e.g. use `default.docker-env` enviroment variables and mount emoncms files from local file-system instead of copy

The third file adds `docker-compose.prod.yml` adds production specific setup.

This setup is based on the recomended Docker method, see [Docker Multiple Compose Files Docs](https://docs.docker.com/compose/extends/#multiple-compose-files).

The development enviroment with the base + override compose is used by default e.g:

    docker-compose up

To run the production compose setup run:

    docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d


## Files, storage & database info

### Files

**By default when running the development compose enviroment (see above) Emoncms files are mounted from the host file system in the `emon_web` Docker container at startup.** This is desirable for dev. For production / deployment / clean testing run production docker compose (see above). This will **copy** emoncms files into the docker container on first run. Any changes made to the files inside the container will be lost when the container is stopped.


### Storage

Storage for feed engines e.g. `var/lib/phpfiwa` are mounted as persistent Docker file volumes e.g.`emon-phpfiwa`. Data stored in these folders is persistent if the container is stopped / started but cannot be accessed outside of the container.

### Database

Database storage `/var/lib/mysql/data` is mounted as persistent Docker volumes e.g.`emon-db-data`. Database data is persistent if the container is stopped / started but cannot be accessed outside of the container.


***

## Useful Docker commands

Show running containers

	$ docker ps

Stop / kill all running containers:

	$ docker stop $(docker ps -a -q)

	$ docker kill $(docker ps -a -q)

Remove all containers:

e.g. emon_web, emon_db

	$ docker rm $(docker ps -a -q)

Remove all images:

e.g. Base images: php-apache, mysql, Ubuntu pulled from Dockerhub

	$ docker rmi $(docker images -q)

Attach a shell to a running container:

	$ docker exec -it emoncms_web_1 /bin/bash