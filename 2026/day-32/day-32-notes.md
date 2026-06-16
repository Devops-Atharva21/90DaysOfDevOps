# Task 1: The Problem – Understanding Data Loss in Containers

## Objective

To understand what happens to data stored inside a Docker container when the container is stopped and removed.

---

## Environment

* Operating System: Ubuntu
* Container Runtime: Docker
* Database Used: PostgreSQL
* Docker Image: `postgres:latest`

---

## Steps Performed

### 1. Started a PostgreSQL container

docker run -d \
  --name postgres-test \
  -e POSTGRES_PASSWORD=admin123 \
  -p 5432:5432 \
  postgres

**Screenshot:** Running PostgreSQL container (`docker ps`).

---

### 2. Connected to PostgreSQL

docker exec -it postgres-test bash
psql -U postgres

---

### 3. Created a database and inserted sample data

CREATE DATABASE testdb;
\c testdb

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO employees (name)
VALUES ('Atharva'),
       ('Docker');

SELECT * FROM employees;

**Output:**

 id |  name
----+---------
  1 | Atharva
**Screenshot:** Table creation and query results.

---

### 4. Stopped and removed the container
docker rm postgres-test

**Screenshot:** Container removal confirmation.

---

### 5. Created a new PostgreSQL container

docker run -d \
  --name postgres-test \
  -e POSTGRES_PASSWORD=admin123 \
  -p 5432:5432 \
  postgres

---

### 6. Verified whether the previous data still existed
psql -U postgres

\c testdb

**Result:**

database "testdb" does not exist

**Screenshot:** Error showing the database was not found.

---

## Observation

The database, tables, and inserted records were no longer available after the original container was removed and a new container was created from the same image.

---

## Why Did This Happen?

Docker containers are ephemeral by default. Any data stored inside a container's writable layer is lost when the container is deleted. Since no Docker Volume or bind mount was configured, PostgreSQL stored its data inside the container itself. Removing the container permanently removed that data.

---

## Key Learnings

* Containers are temporary and disposable.
* Data stored directly inside a container is not persistent.
* Removing a container also removes its writable layer.
* Docker images are immutable templates, while containers are running instances of those images.
* Persistent storage mechanisms such as Docker Volumes are required to retain application data across container recreations.

---

## Conclusion

This task demonstrated the limitations of storing important data directly inside containers. It highlighted the need for persistent storage solutions in Docker-based applications. Docker Volumes solve this problem by keeping data outside the lifecycle of individual containers.


###Task 2: Named Volumes – Persistent Storage in Docker

## Objective

To understand how Docker Named Volumes preserve data independently of a container's lifecycle.

---

## Environment

* Operating System: Ubuntu
* Container Runtime: Docker
* Database: PostgreSQL
* Docker Image: `postgres:latest`

---

## Steps Performed

### 1. Created a Docker Named Volume

docker volume create postgres-data
docker volume ls

---

### 2. Started PostgreSQL using the Named Volume

docker run -d \
  --name postgres-volume \
  -e POSTGRES_PASSWORD=admin123 \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  postgres

---

### 3. Created sample data
\c companydb

CREATE TABLE employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

INSERT INTO employees (name)
VALUES ('Atharva'),
       ('Docker Volume'),
       ('Persistent Storage');

SELECT * FROM employees;

---

### 4. Removed the container

docker stop postgres-volume
docker rm postgres-volume

---

### 5. Created a new container using the same volume

docker run -d \
  --name postgres-volume-new \
  -e POSTGRES_PASSWORD=admin123 \
  -p 5432:5432 \
  -v postgres-data:/var/lib/postgresql/data \
  postgres

---

### 6. Verified data persistence

\c companydb
SELECT * FROM employees;

The previously inserted records were still available.

---

### 7. Inspected the volume

docker volume ls
docker volume inspect postgres-data

---

## Observation

Unlike the previous task, the database and table data remained intact even after the original container was deleted.

---

## Why Did This Happen?

Docker Named Volumes exist independently of containers. PostgreSQL stored its data inside the `postgres-data` volume rather than the container's writable layer. When the container was removed, the volume remained untouched, preserving all database files.

---

## Key Learnings

* Named Volumes provide persistent storage in Docker.
* Volumes survive container deletion.
* Multiple containers can reuse the same volume.
* Volumes are managed by Docker and stored on the host machine.
* Stateful applications such as databases should use volumes.

---

## Conclusion

This task demonstrated how Docker Named Volumes solve the problem of data loss in containers. By separating application data from the container lifecycle, volumes enable reliable and persistent storage for stateful workloads.


# Task 3: Bind Mounts

## Objective

To understand how Docker Bind Mounts enable containers to access files directly from the host machine.

---

## Environment

* Operating System: Ubuntu
* Container Runtime: Docker
* Web Server: Nginx
* Docker Image: `nginx:latest`

---

## Steps Performed

### 1. Created a project directory

mkdir nginx-bind-mount
cd nginx-bind-mount

---

### 2. Created an HTML file on the host machine

nano index.html

Initial content:

<h1>Hello from Bind Mount!</h1>
<p>This page is served by Nginx.</p>

---

### 3. Started an Nginx container using a bind mount

docker run -d \
  --name nginx-bind \
  -p 8080:80 \
  -v $(pwd):/usr/share/nginx/html \
  nginx

---

### 4. Accessed the web page

Opened:

http://localhost:8080

The HTML page was successfully served by Nginx.

---

### 5. Modified the HTML file on the host

Updated `index.html` with new content.

---

### 6. Refreshed the browser

The changes appeared immediately without restarting the container.

---

## Observation

Changes made to files on the host machine were instantly reflected inside the container because the container was directly using the host directory.

---

## Key Learnings

* Bind mounts connect a host directory to a container directory.
* Containers can read and write directly to host files.
* Changes on the host are immediately visible inside the container.
* Bind mounts are useful during development workflows.

---

## Conclusion

Bind mounts provide a convenient way to share files between the host and containers. They are especially useful for local development, where code changes need to be reflected instantly inside running containers.


### Task 4: Docker Networking Basics

## Objective

To understand how containers communicate on Docker's default bridge network.

---

## Environment

* Operating System: Ubuntu
* Container Runtime: Docker
* Docker Image: Ubuntu

---

## Steps Performed

### 1. Listed Docker networks

docker network ls

Observed the default networks:

* bridge
* host
* none

---

### 2. Inspected the default bridge network

docker network inspect bridge

Observed:

* Driver: bridge
* Automatically assigned subnet
* Gateway configuration

---

### 3. Started two Ubuntu containers

docker run -dit --name ubuntu1 ubuntu bash

docker run -dit --name ubuntu2 ubuntu bash

---

### 4. Installed ping utility

apt update
apt install -y iputils-ping

Installed in both containers.

---

### 5. Tested communication by container name

ping ubuntu2

Result:

Temporary failure in name resolution

---

### 6. Retrieved the IP address of Container 2

docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ubuntu2

Example output:

172.17.0.3

---

### 7. Tested communication by IP address

ping 172.17.0.3

Result:

Successful communication between containers.

---

## Observation

Containers attached to Docker's default bridge network were able to communicate using IP addresses but not using container names.

---

## Key Learnings

* Docker automatically creates a bridge network.
* Containers on the default bridge network receive IP addresses automatically.
* Name-based communication does not work on the default bridge network.
* IP-based communication works between containers connected to the same bridge network.
* User-defined bridge networks provide built-in DNS resolution.

---

## Conclusion

This task demonstrated the networking behavior of Docker's default bridge network. Although containers can communicate using IP addresses, service discovery through container names requires user-defined bridge networks.


### Task 5: Custom Networks

## Objective

To understand how Docker user-defined bridge networks enable automatic name-based communication between containers.

---

## Environment

* Operating System: Ubuntu
* Container Runtime: Docker
* Docker Image: Ubuntu

---

## Steps Performed

### 1. Created a custom bridge network

docker network create my-app-net

Verified:

docker network ls

---

### 2. Inspected the custom network

docker network inspect my-app-net

Observed the network configuration including subnet and gateway details.

---

### 3. Started two containers on the custom network
  --name app1 \
  --network my-app-net \
  ubuntu bash

docker run -dit \
  --name app2 \
  --network my-app-net \
  ubuntu bash

---

### 4. Installed ping utility

apt update
apt install -y iputils-ping

Installed inside both containers.

---

### 5. Tested name-based communication

From `app1`:

ping app2

Result:

Successful communication using the container name.

---

### 6. Verified DNS resolution

getent hosts app2

Observed that Docker automatically resolved the container name to its IP address.

---

## Observation

Containers connected to the same custom bridge network were able to communicate using both container names and IP addresses.

---

## Key Learnings

* User-defined bridge networks provide automatic DNS resolution.
* Docker maintains DNS records for containers on custom networks.
* Container names can be used instead of hardcoded IP addresses.
* Custom networks simplify service discovery in containerized applications.

---

## Why Does Custom Networking Allow Name-Based Communication?

Docker's default bridge network does not include automatic DNS-based service discovery. Containers can communicate only through IP addresses.

In contrast, user-defined bridge networks include Docker's embedded DNS server, which automatically maps container names to their corresponding IP addresses. As a result, containers can communicate using names such as `app2` instead of manually discovering IP addresses.

---

## Conclusion

Custom Docker networks improve communication between containers by providing built-in DNS functionality. This makes containerized applications easier to configure, maintain, and scale.


## Task 6: Put It Together

## Objective

To build a simple multi-container environment using Docker networking and volumes, and verify communication between services using container names.

---

## Architecture

app-container ───► postgres-db
                      │
                      ▼
               postgres-data
```

* `my-app-net` → Custom Docker network
* `postgres-data` → Named volume for persistent storage

---

## Environment

* Operating System: Ubuntu
* Container Runtime: Docker
* Database: PostgreSQL 17
* App Container: Ubuntu

---

## Steps Performed

### 1. Created a custom network

docker network create my-app-net

---

### 2. Created a named volume

docker volume create postgres-data

---

### 3. Started PostgreSQL

docker run -d \
  --name postgres-db \
  --network my-app-net \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=companydb \
  -v postgres-data:/var/lib/postgresql/data \
  postgres:17

---

### 4. Started the application container

docker run -dit \
  --name app-container \
  --network my-app-net \
  ubuntu bash

---

### 5. Verified DNS resolution

From the app container:
Result:

ping postgres-db

The database container was successfully resolved using its container name.

---

### 6. Verified database connectivity

nc -zv postgres-db 5432

Result:

The PostgreSQL port was reachable from the application container.

---

### 7. Verified network and volume configuration

docker network inspect my-app-net
docker volume inspect postgres-data

Observed that both containers belonged to the same network and the database used persistent storage.

---

## Observation

The application container successfully communicated with the database container using its container name. Docker's embedded DNS automatically resolved `postgres-db` to the appropriate IP address.

---

## Key Learnings

* Custom networks provide built-in DNS functionality.
* Containers on the same custom network can communicate by name.
* Named volumes persist data independently of containers.
* Multi-container environments can be built using simple Docker commands.
* Docker networking and storage features work together to support stateful applications.

---

## Conclusion

This task demonstrated a practical Docker setup involving networking and persistent storage. The database retained its data through a named volume, while the application container connected to it through Docker's built-in DNS on a custom network.

