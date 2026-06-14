**Task 1: What is Docker?**

**What is Docker** 
Docker is an open-source platform that allows you to package an application and all it required dependencies in a container.

**What is a container and why do we need them?**
A container packages the application along with everything it needs to run. Containers solve the "It works on my machine" problem.

# Task 2: Install Docker

## Objective

Install Docker, verify the installation, and run the hello-world container.

## Steps Performed

### 1. Installed Docker

sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker


### 2. Verified Docker Installation

Command:

docker --version

Output:

Docker version XX.X.X, build XXXXXXX

### 3. Checked Docker Service Status

Command:

sudo systemctl status docker

Result:

Docker service was running successfully.

### 4. Ran the Hello-World Container

Command:

sudo docker run hello-world

Result:

Docker downloaded the hello-world image from Docker Hub, created a container from that image, executed it, displayed a success message, and then stopped the container.

## What I Learned

* Docker uses a client-server architecture.
* Images are templates used to create containers.
* Containers are lightweight, isolated environments.
* Docker automatically pulls images from Docker Hub if they are not available locally.
* The hello-world container is commonly used to verify that Docker is installed correctly.

*** Task 3: Run Real Containers**

## Objective

To understand how to run, interact with, manage, and remove Docker containers.

## Steps Performed

### 1. Ran an Nginx Container

Command:

docker run -d --name nginx-container -p 80:80 nginx

Result:

Successfully started an Nginx container in detached mode and exposed it on port 80.

Accessed the default Nginx welcome page through a web browser.

---

### 2. Ran an Ubuntu Container Interactively

Command:

docker run -it --name ubuntu-container ubuntu

Explored the container using:

pwd
ls
cat /etc/os-release
whoami
uname -a

Result:

Learned that containers provide isolated environments that behave like lightweight Linux systems.

---

### 3. Listed Running Containers

Command:

docker ps

Result:

Displayed all currently running containers.

---

### 4. Listed All Containers

Command:

docker ps -a

Result:

Displayed both active and stopped containers.

---

### 5. Stopped a Container

Command:

docker stop nginx-container

Result:

Successfully stopped the Nginx container.

---

### 6. Removed Containers

Commands:

docker rm nginx-container

Result:

Successfully removed the containers from the system.

## What I Learned

* Docker containers can run real applications such as Nginx.
* Containers can provide interactive Linux environments.
* docker ps shows running containers.
* docker ps -a shows all containers.
* Containers can be stopped and removed when no longer needed.
* Port mapping allows services inside containers to be accessed externally.

