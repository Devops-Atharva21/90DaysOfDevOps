# Day 31 – Your First Dockerfile

## Objective

Create a custom Docker image using Ubuntu, install curl, and configure it to print a message when the container starts.

## Steps Performed

1. Created a project directory named my-first-image.
2. Created a Dockerfile using ubuntu:latest as the base image.
3. Installed curl using the RUN instruction.
4. Added a CMD instruction to print a custom message.
5. Built the image using:


docker build -t my-ubuntu:v1 .


6. Verified the image using:

docker images


7. Ran the container using:

docker run my-ubuntu:v1


## Output

Hello from my custom image!


## Key Learnings

* Dockerfiles automate image creation.
* FROM,RUN, and CMD are fundamental Dockerfile instructions.
* Images can be versioned using tags.
* Containers execute the command defined in CMD by default.


###TASK-2

Objective

Learn and implement the most commonly used Dockerfile instructions by building a simple Docker image.

Steps Performed

###Created a project directory named dockerfile-instructions.
###Developed a simple Python application (app.py).
###Created a Dockerfile demonstrating:
FROM
RUN
WORKDIR
COPY
EXPOSE
CMD
Built the Docker image using:
docker build -t docker-instructions:v1 .
Verified image creation using:
docker images
Ran the container using:
docker run docker-instructions:v1
Output
Hello from Docker!
Key Learnings
Dockerfiles define how custom images are built.
RUN executes commands during build time.
COPY transfers application files into the image.
WORKDIR simplifies file management inside containers.
EXPOSE documents intended network ports.
CMD specifies the default container process.

##TASK-3

Objective

Understand the behavioral differences between CMD and ENTRYPOINT instructions in Dockerfiles.

CMD Experiment
Dockerfile
FROM ubuntu:latest
CMD ["echo", "hello"]
Build
docker build -t cmd-demo:v1 .
Results
docker run cmd-demo:v1

Output:

hello
docker run cmd-demo:v1 ls

Output:

The ls command executed instead of echo hello.
Observation

CMD provides a default command that can be completely overridden during docker run.

ENTRYPOINT Experiment
Dockerfile
FROM ubuntu:latest
ENTRYPOINT ["echo"]
Build
docker build -t entrypoint-demo:v1 .
Results
docker run entrypoint-demo:v1 hello world

Output:

hello world
Observation

ENTRYPOINT defines the main executable. Additional arguments supplied during docker run are appended to it.

CMD vs ENTRYPOINT
CMD	ENTRYPOINT
Sets a default command	Sets the main executable
Can be overridden	Arguments are appended
Suitable for flexible containers	Suitable for fixed-purpose containers
Key Learning
Use CMD when users may need to replace the default behavior.
Use ENTRYPOINT when the container should always execute a specific program.


###TASK-5

Learn how to exclude unnecessary files from Docker build contexts using .dockerignore.

Steps Performed
Created a project directory named dockerignore-demo.
Added sample files and folders:
node_modules
.git
README.md
.env
app.py
Created a Dockerfile that copies the project contents into the image.
Created a .dockerignore file containing:
node_modules
.git
*.md
.env
Built the Docker image using:
docker build -t dockerignore-demo:v1 .
Ran the container to verify which files were copied:
docker run dockerignore-demo:v1
Observation

The ignored files and directories were excluded from the image, even though COPY . . was used.

Key Learnings
.dockerignore reduces Docker build context size.
Sensitive files such as .env should not be included in images.
Excluding unnecessary files improves build performance.
.dockerignore works similarly to .gitignore.

###TASK-6

## Objective

Understand Docker layer caching and learn how Dockerfile instruction order affects build speed.

## Steps Performed

1. Created a simple Python application (`app.py`).
2. Built a Docker image using a Dockerfile containing:

   * FROM
   * RUN
   * WORKDIR
   * COPY
   * CMD
3. Modified the application code and rebuilt the image.
4. Observed Docker reusing unchanged layers from cache.
5. Compared poorly ordered and optimized Dockerfiles.

## Commands Used

docker build -t cache-demo:v1 .

docker build -t cache-demo:v2 .

## Observations

* Docker reused layers that had not changed.
* Changing app.py only rebuilt the COPY layer and subsequent layers.
* Instructions placed before a changed layer remained cached.

## Why Layer Order Matters

Docker evaluates instructions sequentially. When a layer changes, Docker invalidates the cache for that layer and all layers that follow it. Placing frequently changing instructions near the end of the Dockerfile improves build performance.

## Key Learnings

* Docker images are built in layers.
* Cache significantly reduces rebuild time.
* Stable instructions should appear early.
* Frequently changing instructions should appear later.
* Proper Dockerfile design improves developer productivity.
