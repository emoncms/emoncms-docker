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

If running on Linux highly recommended to create Docker group to avoid having to use `sudo` with Docker commands:

```bash
sudo groupadd docker
sudo usermod -aG docker $USER
docker run hello-world
```

After restarting terminal (logout & log back in), you should now be able to `docker run hello-world` without `sudo`.


# Quick start

Pull [openenergymonitor/emoncms:latest](https://hub.docker.com/r/openenergymonitor/emoncms/) from docker hub and use Docker-compose to link the Emoncms container (PHP & Apache) to the MYSQL container.

```bash
git clone https://github.com/emoncms/emoncms-docker
cd emoncms-docker
./bin/setup_dev_repositories
docker pull openenergymonitor/emoncms:latest
docker-compose up
```

**That's it! Emoncms should now be running in Docker container, browse to [http://localhost:8080](http://localhost:8080)**

### Setup dev environment

If you want to edit the emoncms file (dev) it's best to clone them externally to docker then mount volume into the container:

Uncomment in `docker-compose.override.yml`:

```yaml
volumes:
  ##mount emoncms files from local FS for dev
  - ./emoncms:/var/www/emoncms
```
Then clone the repos into `./emoncms`

```bash
./bin/setup_dev_repositories
docker-compose pull
docker-compose up
```


If you get an error `bind: address already in use`, this means there is already a process on the host machine listening on port 8080. You can check what processes are listening on ports by running `sudo netstat -plnt`. There are two options, either change the [emoncms web container port](https://github.com/emoncms/emoncms-docker/blob/master/docker-compose.override.yml#L9) to use a different port then rebuild the container or kill the process currently running on the host machine using the same port.   

***

## Build Emoncms Docker Containers

#### Git Clone

*Note: If Emoncms Docker being used for production / testing (i.e modifying the Emoncms files at run-time is not required) there is no need to clone emoncms core & modules since by default the Emoncms git master branch is cloned when the containers are built (see Dockerfile), this cloned 'snapshot' is then overwritten by the Emoncms files mounted from local file-system when running development docker-compose (default)*

Run the following script to clone the `emoncms` repository along with the `dashboard` and `graph` modules:

```bash
./bin/setup_dev_repositories
```

*Further modules can be found in the [emoncms git repo](https://github.com/emoncms/) e.g. backup, WiFi etc.*

The file structure should look like:

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

```bash
docker-compose build
```

### Start Emoncms containers

Start as foreground service:

```bash
docker-compose up
```

Stop with [CTRL + c]


**That's it! Emoncms should now be runnning in Docker container, browse to [http://localhost:8080](http://localhost:8080)**


Start as background service:

```bash 
docker-compose up -d
``` 

Stop the containers

```bash
docker-compose down 
```
Stop the containers and delete the volumes (remove database and all stored data)

```bash
docker-compose down -v
```

**Docker compose up will start two containers:**

1. `emon_web` which is based on the official [Docker PHP-Apache image](https://hub.docker.com/_/php)
2. `emon_db` which is based on the official [Docker MySQL image](https://hub.docker.com/_/mysql)

***
***

### How Docker Compose works...

Infomation about how docker-compose working in Emoncms Docker.

#### Development Vs Production

There are three docker compose files:

1. `docker-compose.yml`
2. `docker-compose.override.yml`
3. `docker-compose.prod.yml`

The first `docker-compose.yml` defines the base config; things that are common to both development and production.

The second file `docker-compose.override.yml` defines additional things for development environment e.g. use `default.docker-env` environment variables and *mount* emoncms files from local file-system instead of *copy* into container.

The third file `docker-compose.prod.yml` defines production specific setup e.g. expose port 80 and *copy* in files instead of *mount*. The production docker-compose file  is `docker-compose.prod.yml` instead of `docker-compose.override.yml` when the Emoncms Docker contains are ran as 'production'

This setup is based on the recommended Docker method, see [Docker Multiple Compose Files Docs](https://docs.docker.com/compose/extends/#multiple-compose-files).

#### Development

The development enviroment with the base + override compose is used by default e.g:

```bash
docker-compose up
```

#### Production

To run the production compose setup run:

```bash
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Files, storage & database info

Infomation about how files and databases work in Emoncms Docker.

#### Files

**By default when running the development compose enviroment (see above) Emoncms files are mounted from the host file system in the `emon_web` Docker container at startup.** This is desirable for dev. For production / deployment / clean testing run production docker compose (see above). This will **copy** emoncms files into the docker container on first run. Any changes made to the files inside the container will be lost when the container is stopped.


#### Storage

Storage for feed engines e.g. `var/lib/phpfiwa` are mounted as persistent Docker file volumes e.g.`emon-phpfiwa`. Data stored in these folders is persistent if the container is stopped / started but cannot be accessed outside of the container. See below for how to list and remove docker volumes.

#### Database

Database storage `/var/lib/mysql/data` is mounted as persistent Docker volumes e.g.`emon-db-data`. Database data is persistent if the container is stopped / started but cannot be accessed outside of the container.


***

### Useful Docker commands

List running containers

```bash 
docker ps
```

List all containsers 
```bash
docker ps -a
```

Stop / kill all running containers:
mysql
e.g. `emon_web`, `emon_db`

```bash
	docker rm $(docker ps -a -q)
```

List all base images:

```bash
docker image ls
```	

Remove all images:

e.g. Base images: php-apache, mysql, Ubuntu pulled from Dockerhub

```bash
docker rmi $(docker images -q)
```

List docker volumes (where data is stored e.g database) 

```bash
docker volume ls
```

Remove single or all docker volumes

```bash
docker volume rm <name_of_volume>
docker volume prune
```
Attach a shell to a running container:

```bash
docker exec -it emoncms-docker_web_1 /bin/bash
```

****

## Pushing to docker hub 

From: https://docs.docker.com/docker-hub/repos/

```bash
docker login --username=yourhubusername --email=youremail@company.com
docker tag openenergymonitor/emoncms:<tag-name>
docker push openenergymonitor/emoncms:<tag-name>
```

Tag name should be the Emoncms version e.g 10.x.x

Also push the latest version using `latest` tag

```bash
docker tag openenergymonitor/emoncms:latest
docker tag openenergymonitor/emoncms:latest
```
