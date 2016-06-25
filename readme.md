Using Docker it's possible to fire up Emoncms on a bare system (assuming Docker is installed) in a couple of minutes with all the LAMP installing and config taken care of.

This is great for development since it's possible to play about with Emoncms running in a Docker container without fear of messing up your main Emoncms install.

In the future, Docker can even be used as a deployment tool for Emoncms. In theory, it should be possible to deploy the Docker container on any server within minutes :-)

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

You should now be able to `docker run hello-world` without `sudo`.

## Use Docker image

*Pull emoncms image from docker hub (yet to be pushed)*

Pulling the emoncms image from docker up is the easiest way to fire up emoncms for production* or testing. For development you will probably want to build the image yourself to have full control.

\* **Docker image is currently in early testing and is NOT yet recommended for production**



## Build Emoncms Docker Containers


#### Git Clone

clone `emoncms-docker` (this repo):

	$ git clone https://github.com/emoncms/emoncms-docker

Inside `emoncms-docker` clone emoncms-core:

**Note: If the container(s) are only being used for production / testing there is no need to clone emoncms core & modules since by default the master branch is cloned when the container(s) are built (see Dockerfile), this cloned 'snapshot' is overwritten by the Emoncms files mounted from local file-system when running development docker-compose (default)**

	$ cd emoncms-docker
	$ git clone https://github.com/emoncms/emoncms

Clone in optional modules (`graph` and `dashboard` are highly recommended):

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

#### Customise config

##### MYSQL Database Credentials

For development the default settings in `default.docker.env` are used. For production a `.env` file should be created with secure database Credentials. See Production setup info below.

##### PHP Config

Edit `config/php.ini` to add custom php settings e.g. timezone (default Europe)

#### Build / update Docker container

Required on first run or if `Dockerfile` or `Docker-compose.yml` are changed:

	$ docker-compose build


### Start Emoncms containers

Start as foreground service:

	$ docker-compose up

Stop with [CTRL + c]

**That's it! Emoncms should now be runnning in Docker container, browse to [http://localhost:8080](http://localhost:8080)**

Start as background service:

	$ docker-compose up -d

**Docker compose up will start two containers:**

1. `emon_web` which is based on the official [Docker PHP-Apache image](https://hub.docker.com/_/php)
2. `emon_db` which is based on the offical [Docker MYSQL image](https://hub.docker.com/_/mysql)

***
***

### How Docker Compose works...

Infomation about how docker-copose workin in Emoncms Docker.

#### Development Vs Production

There are three docker compose files:

1. `docker-compose.yml`
2. `docker-compose.override.yml`
3. `docker-compose.prod.yml`

The first `docker-compose.yml` defines the base config; things that are common to both development and production.

The second file `docker-compose.override.yml` defines additional things for development enviroment e.g. use `default.docker-env` enviroment variables and *mount* emoncms files from local file-system instead of *copy* into container.

The third file `docker-compose.prod.yml` defines production specific setup e.g. expose port 80 and *copy* in files instead of *mount*. The production docker-compose file  is `docker-compose.prod.yml` instead of `docker-compose.override.yml` when the Emoncms Docker contains are ran as 'proudcution'

This setup is based on the recomended Docker method, see [Docker Multiple Compose Files Docs](https://docs.docker.com/compose/extends/#multiple-compose-files).

#### Development

The development enviroment with the base + override compose is used by default e.g:

    $ docker-compose up

#### Production

To run the production compose setup run:

    $ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d


### Files, storage & database info

Infomation about how files and databases work in Emoncms Docker.

#### Files

**By default when running the development compose enviroment (see above) Emoncms files are mounted from the host file system in the `emon_web` Docker container at startup.** This is desirable for dev. For production / deployment / clean testing run production docker compose (see above). This will **copy** emoncms files into the docker container on first run. Any changes made to the files inside the container will be lost when the container is stopped.


#### Storage

Storage for feed engines e.g. `var/lib/phpfiwa` are mounted as persistent Docker file volumes e.g.`emon-phpfiwa`. Data stored in these folders is persistent if the container is stopped / started but cannot be accessed outside of the container.

#### Database

Database storage `/var/lib/mysql/data` is mounted as persistent Docker volumes e.g.`emon-db-data`. Database data is persistent if the container is stopped / started but cannot be accessed outside of the container. If access to the database files for debugging, you can fire up a new container and attach the `emon-db-data` docker volume containing the db files:

```
docker run \
  -it \
  --rm \
  -v emon-db-data:/var/lib/mysql \
  mysql \
  bash
```

***

### Useful Docker commands

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
