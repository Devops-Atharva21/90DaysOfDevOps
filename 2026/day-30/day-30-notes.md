# Day 30 - Docker Images

## Objective

Learn how to manage Docker images by pulling, listing, inspecting, comparing, and removing them.

---

## Task 1: Pull Docker Images

Pulled the official Docker images from Docker Hub.

docker pull nginx
docker pull ubuntu
docker pull alpine


Verified the downloaded images:

docker images


---

## Task 2: List Docker Images

Listed all images available on the local machine.

docker images


**Observation:** Alpine had the smallest image size compared to Ubuntu and Nginx.

---

## Task 3: Compare Ubuntu vs Alpine

| Ubuntu                 | Alpine                          |
| ---------------------- | ------------------------------- |
| Larger image size      | Smaller image size              |
| Usesapt           | Usesapk                    |
| Includes more packages | Minimal packages                |
| Good for development   | Good for lightweight containers |

**Observation:** Alpine is smaller because it contains only essential components.

---

## Task 4: Inspect an Image

Inspected the Ubuntu image to view its metadata.

docker inspect ubuntu


Information observed:

* Image ID
* Creation date
* Operating system
* Architecture
* Environment variables
* Image layers

---

## Task 5: Remove an Unused Image

Removed the Alpine image from the local system.

docker rmi alpine


Verified removal:

docker images

---

## Key Learnings

* Docker images are templates used to create containers.
* Docker Hub stores official Docker images.
* docker pullvdownloads images.
* docker imagesvlists local images.
* docker inspectvshows detailed image information.
* docker rmivremoves unused images.
* Alpine images are lightweight and efficient.

---

## Commands Summary

docker pull nginx
docker pull ubuntu
docker pull alpine

docker images

docker inspect ubuntu

docker rmi alpine


### Task 2 - Docker Image Layers

## Objective

Understand how Docker images are built using layers.

---

## Commands Used

docker image history nginx

or

docker history nginx

---

## Observation

The command displayed the history of the Nginx image. Each line in the output represented an image layer created during the image build process.

I observed that:

* Some layers had a size because they added files, installed packages, or modified the filesystem.
* Some layers showed 0B because they contained only metadata instructions such as CMD, EXPOSE, or ENV.

---

## What Are Docker Layers?

Docker images are made up of multiple read-only layers stacked on top of each other. Each instruction in a Dockerfile creates a new layer.

Examples:

* RUN apt install nginx` creates a new layer with added files.
* CMD ["nginx", "-g", "daemon off;"] creates a metadata layer with 0B size.

---

## Why Does Docker Use Layers?

Docker uses layers because they:

* Improve build performance through layer caching.
* Reduce storage usage by reusing existing layers.
* Speed up image downloads and uploads by transferring only changed layers.
* Make image management more efficient.

---

## Key Learning

Docker images are not a single file; they are a collection of reusable layers that help optimize storage, performance, and portability.

## Task 3 - Container Lifecycle

## Objective

Understand the different states in a Docker container's lifecycle by performing common container management operations.

---

## Commands Used

Create a container without starting it:

docker create --name lifecycle-demo nginx

Check container status:

docker ps -a

Start the container:

docker start lifecycle-demo

Pause the container:

docker pause lifecycle-demo

Unpause the container:

docker unpause lifecycle-demo

Stop the container:

docker stop lifecycle-demo

Restart the container:

docker restart lifecycle-demo

Kill the container:

docker kill lifecycle-demo

Remove the container:

docker rm lifecycle-demo

---

## Observations

| Action  | Container State |
| ------- | --------------- |
| Create  | Created         |
| Start   | Up              |
| Pause   | Paused          |
| Unpause | Up              |
| Stop    | Exited          |
| Restart | Up              |
| Kill    | Exited          |
| Remove  | Removed         |

I used `docker ps -a` after each step to observe how the container state changed throughout its lifecycle.

---

## Key Learning

Docker containers move through different states during their lifecycle. Understanding these states helps in managing, troubleshooting, and maintaining containerized applications effectively.

* create prepares a container without running it.
* start runs the container.
* pause temporarily suspends all processes.
* unpause resumes execution.
* stop gracefully terminates the container.
* restart stops and starts the container again.
* kill forcefully terminates the container immediately.
* rm permanently removes the container from the system.


## Task 4 - Working with Running Containers

## Objective

Learn how to interact with running Docker containers by viewing logs, executing commands, and inspecting container details.

---

## Commands Used

Run an Nginx container in detached mode:

docker run -d --name nginx-demo -p 8080:80 nginx

List running containers:

docker ps

View container logs:

docker logs nginx-demo

View real-time logs:

docker logs -f nginx-demo

Access the container shell:

docker exec -it nginx-demo /bin/bash

Run a single command inside the container:

docker exec nginx-demo ls /usr/share/nginx/html

Inspect the container:

docker inspect nginx-demo

Find the container IP address:

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-demo

View port mappings:

docker port nginx-demo

View mounts:

docker inspect -f '{{json .Mounts}}' nginx-demo

---

## Observations

* The container ran successfully in detached mode.
* Container logs helped monitor the application's activity.
* Follow mode displayed logs in real time.
* Using docker exec, I explored the container's filesystem.
* Single commands could be executed without entering the container shell.
* The docker inspect command provided detailed information such as the container's IP address, port mappings, and mount configurations.

---

## Key Learning

Docker provides several commands to monitor and manage running containers. Understanding how to view logs, execute commands, and inspect container details is essential for troubleshooting and administering containerized applications.
