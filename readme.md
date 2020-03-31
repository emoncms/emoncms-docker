Using Docker it's possible to fire up Emoncms on a bare system (assuming Docker is installed) in a couple of minutes with all the LAMP install & config taken care of.

This is great for development since it's possible to play about with Emoncms running in a Docker container without fear of messing up your main Emoncms install.

In the future, Docker can even be used as a deployment tool for Emoncms. In theory, it should be possible to deploy the Docker container on any server within minutes :-)

We have taken a multi-container approach with php-apache running in one container and the MYSQL database running in another. The containers are linked using [docker-compose](https://docs.docker.com/compose).


[**To do list**](https://github.com/emoncms/emoncms-docker/issues/2)

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

After restarting terminal (logout & logback in), you should now be able to `docker run hello-world` without `sudo`.


# Quick start

Run docker compose to pull [openenergymonitor/emoncms:latest](https://hub.docker.com/r/openenergymonitor/emoncms/) from docker hub and run.

```
$ git clone https://github.com/emoncms/emoncms-docker
$ cd emoncms-docker
$ docker-compose up --detach
```


**That's it! Emoncms should now be running in Docker container, browse to [http://localhost:8888](http://localhost:8888)**



# Install on Raspberry Pi
if you're using a fresh install of [Raspian Buster](https://www.raspberrypi.org/downloads/raspbian/) you could run this script setup and install EmonCMS...

```
wget https://raw.githubusercontent.com/emoncms/emoncms-docker/v2/install.sh chmod +x init.sh && ./init.sh
```

***

# Customise config
## Editing .env
All the available settings are set in the file `.env` eg:
```
WEB_PORT=8888
MQTT_PORT=1883
DEFAULT_LANG=en_GB
PHP_VERSION=7.4
```
## Errors:
If you get an error `bind: address already in use`, this means there is already a process on the host machine listening on port 8888. You can check what processes are listening on ports by running `sudo netstat -plnt`.
Edit the `.env` file setting `WEB_PORT=8888` and re-run the `docker up -d` command to restart.

## MYSQL Database Credentials

For development the default settings in `default.docker.env` are used. For production a `.env` file should be created with secure database Credentials. See Production setup info below.

## PHP Config

Edit `config/php.ini` to add custom php settings e.g. timezone (default Europe)

## Build / update Docker container

Start as background service:
```
    $ docker-compose up -d
```
Stop the containers
```
    $ sudo docker-compose down
```
Stop the containser and delete the volumes (remove database and all stored data)
```
    $ sudo docker-compose down -v
```

**Docker compose up will start 6 containers:**

1. `mqtt` official mosquitto image [Docker eclipse-mosquitto](https://hub.docker.com/_/eclipse-mosquitto)
1. `db` official MariaDB image [Docker mariadb](https://hub.docker.com/_/mariadb)
1. `php` official php 7.4 image (fpm variant) with additional php modules being installed during build [Docker php](https://hub.docker.com/_/php)
1. `apache` official apache image (alpine variant) [Docker httpd](https://hub.docker.com/_/httpd)
1. `redis` official redis image [Docker redis](https://hub.docker.com/_/redis)
1. `emoncms_feedwriter` official alpine image with cgi scripting installed during build [Docker alpine](https://hub.docker.com/_/alpine)
1. `emoncms_mqtt` official alpine image with cgi scripting installed during build [Docker alpine](https://hub.docker.com/_/alpine)
1. `emoncms_service-runner` official python 3.8 image (slim variant) with additional python modules being installed during build [Docker python](https://hub.docker.com/_/python)
1. `emonhub` official python 3.8 image (slim variant) with additional python modules being installed during build [Docker python](https://hub.docker.com/_/python)

> **Help wanted** - Pull requests to reduce the size of any of the above containers would be appreciated. [Multi-stage](https://docs.docker.com/develop/develop-images/multistage-build/) could be an approach to reduce all to software compliation requirements from the final images?...

***

# Setup Dev enviroment

If you want to edit the emoncms file (dev) it's best to clone them externally to docker then mount volume into the container:

Uncomment in `docker-compose.override.yml`:

```
volumes:
  ##mount emoncms files from local FS for dev
  - ./emoncms:/var/www/html
```

Then clone the repos:
```
git clone https://github.com/emoncms/emoncms.git ./emoncms
git clone https://github.com/emoncms/dashboard.git ./emoncms/Modules/dashboard
git clone https://github.com/emoncms/graph.git ./emoncms/Modules/graph
```
Further modules can be found in the ***[emoncms git repo](https://github.com/emoncms/)*** e.g. backup, wifi etc.

The file structure should look like:

```
+-- emoncms-docker
¦   +-- <docker-compose files>
¦   +-- install.sh
¦   +-- docker-compose.yml
+-- emoncms
¦   +-- <emoncms-core files>
¦   +-- e.g index.php
¦   +-- Modules
¦       +-- <core-modules> e.g. admin, feed, input
¦       +-- <optional-modules> e.g dashboard
```
Then start the containers _(in --detach mode -d )_:
```
$ docker-compose up -d
```

***
## How Docker Compose works...
Infomation about how docker-copose workin in Emoncms Docker.

#### Development Vs Production

There are three docker compose files:

1. `docker-compose.yml`
2. `docker-compose.override.yml`
3. `docker-compose.prod.yml`

The first `docker-compose.yml` defines the base config; things that are common to both development and production.

The second file `docker-compose.override.yml` defines additional things for development enviroment e.g. use `default.docker-env` enviroment variables and *mount* emoncms files from local file-system instead of *copy* into container.

The third file `docker-compose.prod.yml` defines production specific setup e.g. expose port 80 and *copy* in files instead of *mount*. The production docker-compose file  is `docker-compose.prod.yml` instead of `docker-compose.override.yml` when the Emoncms Docker contains are ran as 'production'

This setup is based on the recomended Docker method, see [Docker Multiple Compose Files Docs](https://docs.docker.com/compose/extends/#multiple-compose-files).

### Development

The development enviroment with the base + override compose is used by default e.g:

    $ docker-compose up

### Production

To run the production compose setup run:

    $ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d


## Files, storage & database info

Infomation about how files and databases work in Emoncms Docker.

### Files

All the files are within the docker volumes by default. If you'd like to edit the files on your machine to test new emoncms features or modules you could mount (link to) a directory on your machine to act as the web directory for emoncms...

Uncomment the mount section from `docker-compose.override.yml`
```
volumes:
  ##mount emoncms files from local FS for dev
  ##- ./emoncms:/var/www/html
```
> ensure that you have a directory to use as the first value `[your machine]:[docker container]`):


### Storage

Storage for feed engines e.g. `var/lib/phpfiwa` are mounted as persistent Docker file volumes e.g.`phpfiwa`. Data stored in these folders is persistent if the container is stopped / started but cannot be accessed outside of the container. See below for how to list and remove docker volumes.
> these could also be changed in the `override.yml` file

### Database

Database storage `/var/lib/mysql/data` is mounted as persistent Docker volumes e.g.`db`. Database data is persistent if the container is stopped / started but cannot be accessed outside of the container.
> these could also be changed in the `override.yml` file


***

### Useful Docker commands

List running containers

    $ docker ps

List all containsers

    $ docker ps -a

Stop / kill all running containers:

    $ docker stop $(docker ps -a -q)

    $ docker kill $(docker ps -a -q)

Remove all containers:

e.g. emon_web, emon_db

    $ docker rm $(docker ps -a -q)

List all base images

    $ docker image ls

Remove all images:

e.g. Base images: php-apache, mysql, Ubuntu pulled from Dockerhub

    $ docker rmi $(docker images -q)

List docker volumes (where data is stored e.g database)

     $ docker volume ls

Remove single or all docker volumes

    $ docker volume rm <name_of_volume>
    $ docker volume prune

Attach a shell to a running container:

    $ docker exec -it emoncmsdocker_web_1 /bin/bash

****

## Pushing to docker hub

From: https://docs.docker.com/docker-hub/repos/

```
$ docker login --username=yourhubusername --email=youremail@company.com
$ docker tag openenergymonitor/emoncms:<tag-name>
$ docker push openenergymonitor/emoncms:<tag-name>
```
Tag name should be the Emoncms version e.g 10.x.x

Also push the latest version using `latest` tag

```
$ docker tag openenergymonitor/emoncms:latest
$ docker tag openenergymonitor/emoncms:latest
```
