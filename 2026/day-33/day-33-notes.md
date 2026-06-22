Docker Compose Installation & Verification

### TASK -1 

Objective

Install Docker Compose and verify that it is working correctly.

Installation

Update package list:

sudo apt update

Install Docker Compose plugin:

sudo apt install docker-compose-plugin -y
Verification

Check Docker Compose version:

docker compose version

Example output:

Docker Compose version v2.x.x
Test

Create a simple Nginx container:

services:
  nginx:
    image: nginx
    ports:
      - "8080:80"

Start the container:

docker compose up -d

Verify:

docker compose ps

Open:

http://localhost:8080

Stop and remove resources:

docker compose down
Outcome
Installed Docker Compose plugin.
Verified the installed version.
Successfully deployed an Nginx container using Docker Compose.
Confirmed container accessibility and cleaned up resources.


### Task 2: Your First Docker Compose File

## Objective

Create and run a simple Docker Compose application using a single Nginx container.

## Project Structure

compose-basics/
└── docker-compose.yml

## Docker Compose File

services:
  nginx:
    image: nginx
    container_name: nginx-compose
    ports:
      - "8080:80"

## Commands Executed

Create project directory:

mkdir compose-basics
cd compose-basics

Start the container:

docker compose up -d

Verify container status:

docker compose ps

Access application:

http://localhost:8080

Stop and remove resources:

docker compose down

## Observations

* Docker Compose created and started the Nginx container.
* Port 8080 on the host was mapped to port 80 inside the container.
* The Nginx welcome page was accessible from the browser.
* `docker compose down` successfully stopped and removed the container.

## Outcome

Successfully created and executed a Docker Compose file to deploy a single Nginx container and manage its lifecycle using Docker Compose.


#Task 3: WordPress and MySQL Multi-Container Application
Objective

Deploy a WordPress application with a MySQL database using Docker Compose and verify data persistence using a named volume.

Architecture
Browser
   │
   ▼
WordPress Container
   │
   ▼
MySQL Container
   │
   ▼
Named Volume (mysql_data)

Docker Compose File
services:
  db:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wpuser
      MYSQL_PASSWORD: wppassword
    volumes:
      - mysql_data:/var/lib/mysql

  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: db:3306
      WORDPRESS_DB_USER: wpuser
      WORDPRESS_DB_PASSWORD: wppassword
      WORDPRESS_DB_NAME: wordpress
    depends_on:
      - db

volumes:
  mysql_data:

Commands Executed

Start application:

docker compose up -d

Verify containers:

docker compose ps

Verify volume:

docker volume ls

Stop application:

docker compose down

Restart application:

docker compose up -d

Observations

Docker Compose automatically created a shared network.
WordPress connected to MySQL using the service name db.
A named volume stored MySQL database files.
WordPress setup was completed successfully through the browser.
Data remained available after stopping and recreating containers.


#### Task 4: Docker Compose Commands

## Objective

Practice common Docker Compose commands used for managing multi-container applications.

## Commands Practiced

### Start Services

docker compose up -d

Starts all services in detached mode.

### View Running Services

docker compose ps

Displays the status of all containers in the Compose project.

### View Logs of All Services

docker compose logs

Displays logs from all running services.

### View Logs of a Specific Service

docker compose logs wordpress
docker compose logs db

Displays logs for a selected service.

### Stop Services Without Removing

docker compose stop

Stops containers while preserving them.

### Start Stopped Services

docker compose start

Restarts previously stopped containers.

### Remove Containers and Networks

docker compose down

Removes containers and the default network created by Docker Compose.

### Rebuild Images

docker compose build
docker compose up -d --build

Rebuilds container images after changes.

## Observations

* Services can be started and managed using a single command.
* Logs help troubleshoot container issues.
* Containers can be stopped and restarted without recreation.
* `docker compose down` removes containers and networks.
* Rebuilding images applies application changes.

## Outcome

Successfully practiced Docker Compose lifecycle management commands including starting, stopping, logging, rebuilding, and removing services.

