# Day 34 – Docker Compose: Build Your Own App Stack

## Objective

The goal of this task was to build a multi-container application using Docker Compose. The stack consists of:

* Flask Web Application
* PostgreSQL Database
* Redis Cache

This exercise demonstrates how multiple services can run together and communicate through a Docker Compose network.

---

# Architecture


                    +------------------+
                    |      User        |
                    +--------+---------+
                             |
                             v
                    +------------------+
                    |   Flask Web App  |
                    +--------+---------+
                             |
               +-------------+-------------+
               |                           |
               v                           v
      +------------------+      +------------------+
      |    PostgreSQL    |      |      Redis       |
      |    Database      |      |      Cache       |
      +------------------+      +------------------+


---

# Project Structure


day-34-app-stack/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
└── docker-compose.yml


---

# Application Code

## app.py

The Flask application performs the following tasks:

* Starts a web server on port 5000
* Connects to PostgreSQL
* Connects to Redis
* Stores and retrieves a sample message from Redis
* Displays a success message in the browser

### Key Concepts

* Uses service name `db` to connect to PostgreSQL
* Uses service name `redis` to connect to Redis
* Demonstrates Docker Compose internal DNS resolution

---

# Dockerfile

dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["python", "app.py"]


## Dockerfile Explanation

| Instruction | Purpose                     |
| ----------- | --------------------------- |
| FROM        | Uses Python 3.12 slim image |
| WORKDIR     | Sets working directory      |
| COPY        | Copies application files    |
| RUN         | Installs required packages  |
| EXPOSE      | Opens port 5000             |
| CMD         | Starts Flask application    |

---

# Docker Compose Configuration

yaml
services:

  web:
    build: ./app
    container_name: flask-app

    ports:
      - "5000:5000"

    depends_on:
      - db
      - redis

  db:
    image: postgres:16

    container_name: postgres-db

    environment:
      POSTGRES_DB: mydb
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres

    volumes:
      - postgres-data:/var/lib/postgresql/data

  redis:
    image: redis:7

    container_name: redis-cache

volumes:
  postgres-data:


---

# Service Details

## Web Service

* Built from local Dockerfile
* Runs Flask application
* Exposes port 5000 to host machine
* Depends on PostgreSQL and Redis

## Database Service

* Uses PostgreSQL 16 image
* Stores data persistently using Docker Volume
* Configured using environment variables

## Cache Service

* Uses Redis 7 image
* Provides fast in-memory key-value storage

---

# Docker Compose Features Used

## Custom Build

bash
docker compose build


Builds the Flask image from the Dockerfile.

## Service Networking

Docker Compose automatically creates a dedicated network where services can communicate using service names.

Example:

python
host="db"
host="redis"


No IP addresses are required.

## Persistent Storage

yaml
volumes:
  - postgres-data:/var/lib/postgresql/data


The database data remains intact even if the container is removed.

---

# Commands Executed

## Build and Start Containers

bash
docker compose up -d --build

## Verify Running Containers

bash
docker compose ps

## View Logs

bash
docker compose logs web

docker compose logs db

docker compose logs redis


## List Networks

bash
docker network ls


## Inspect Compose Network

bash
docker network inspect day-34-app-stack_default

## Stop Services

bash
docker compose down

---

# Verification

Open the application:

http://localhost:5000

Expected Output:

Flask App Running
Database Connected Successfully
Redis Message: Hello from Redis!

---

# Screenshots

Include screenshots of:

### 1. Docker Compose Services

bash
docker compose ps

### 2. Browser Output

http://localhost:5000

### 3. Container Logs

bash
docker compose logs web

### 4. Docker Network Inspection

bash
docker network inspect day-34-app-stack_default


### TASK -2

Objective

The goal of this task was to ensure that the web application starts only after the PostgreSQL database is fully initialized and ready to accept connections.

This was achieved using:

Docker Compose depends_on
PostgreSQL Healthchecks
service_healthy condition
Problem Statement

A container can be in a running state while the application inside it is still initializing.

Without healthchecks:

PostgreSQL Container Started
        ↓
Flask App Started
        ↓
Database Not Ready
        ↓
Connection Failure
Solution

Implemented a PostgreSQL healthcheck using the pg_isready command and configured the Flask application to wait until the database became healthy.

Healthcheck Configuration
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres -d mydb"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 10s

Explanation
Parameter	Purpose
test	Checks database readiness
interval	Runs every 10 seconds
timeout	Fails after 5 seconds
retries	Requires 5 failures before unhealthy
start_period	Initial grace period
depends_on Configuration

depends_on:
  db:
    condition: service_healthy

This ensures that the Flask application starts only after PostgreSQL passes its healthcheck.

Commands Executed

docker compose down

docker compose down -v

docker compose up --build

docker ps

docker inspect postgres-db
Verification

Observed the following startup sequence:

PostgreSQL Container Started
        ↓
Healthcheck Executed
        ↓
Database Marked Healthy
        ↓
Flask Application Started

The application successfully connected to PostgreSQL without any startup failures.

### TASK 4

Objective

The goal of this task was to understand Docker restart policies and how they help recover containers automatically after failures.

The restart policies tested were:

restart: always
restart: on-failure
What Are Restart Policies?

Restart policies define how Docker should respond when a container stops unexpectedly.

They improve application availability and reduce manual intervention.

Testing restart: always
Configuration
db:
  image: postgres:16
  restart: always
Test Performed

Started the PostgreSQL container:

docker compose up -d

Manually killed the container:

docker kill postgres-db
Result

Docker automatically restarted the container.

Verification:

docker inspect postgres-db

Observed:

"RestartCount": 1

This confirmed that Docker detected the failure and restarted the service automatically.

Testing restart: on-failure
Configuration
db:
  image: postgres:16
  restart: on-failure
Test 1: Container Failure
docker kill postgres-db

Result:

Container restarted automatically because it exited with a failure condition.

Test 2: Manual Stop
docker stop postgres-db

Result:

Container remained stopped.

Docker did not restart it because the shutdown was intentional


###TASK 4

Objective

Use a custom Dockerfile with Docker Compose instead of a pre-built image. Make a code change and rebuild the application using a single command.

Dockerfile
FROM python:3.12-slim

WORKDIR /app

COPY . .

CMD ["python", "app.py"]
docker-compose.yml
services:
  web:
    build: .
    container_name: web-app
    ports:
      - "5000:5000"
Build and Run
docker compose up --build -d

This command builds the image, creates the container, and starts the application.

Code Change

Updated the application code to verify that Docker Compose rebuilds the image correctly.

Example:

print("Hello Docker Compose")
Rebuild and Restart
docker compose up --build -d

Docker Compose rebuilds the image and recreates the container with the latest changes.

Verification

Check running containers:

docker ps

Check application logs:

docker logs web-app

### TASK 5

Objective

Learn how to use named networks, named volumes, and labels in Docker Compose.

Named Network

Created a custom network:

networks:
  app-network:
    driver: bridge

Both web and database services use this network for communication.

Named Volume

Created a named volume for PostgreSQL data:

volumes:
  postgres-data:

Attached it to the database container:

volumes:
  - postgres-data:/var/lib/postgresql/data

This ensures data persists even if the container is removed.

Labels

Added labels to organize services:

labels:
  project: "docker-compose-practice"
  environment: "dev"
Commands Used
docker compose up -d
docker network ls
docker volume ls
docker inspect web-app


###TASK 6

Objective

Scale a web application to 3 replicas using Docker Compose and observe the behavior.

Scaling Command
docker compose up -d --scale web=3
Observation

The web service was configured with:

ports:
  - "5000:5000"

Docker attempted to start multiple replicas of the same service.

What Happened?

Only one container could use host port 5000.

Additional replicas failed because the port was already allocated.

Example error:

Bind for 0.0.0.0:5000 failed: port is already allocated
Why Doesn't Simple Scaling Work With Port Mapping?

A host port can only be bound to one container at a time.

When multiple replicas try to use the same host port, Docker cannot start them all.

How Scaling Works in Production

A load balancer such as NGINX sits in front of multiple application replicas and distributes incoming traffic.

Client
  |
NGINX
  |
+------+------+------+
| web1 | web2 | web3 |
+------+------+------+

