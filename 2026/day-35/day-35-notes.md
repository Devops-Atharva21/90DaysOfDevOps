Day 35 – The Problem with Large Images

### TASK 1

Objective

Understand why container images can become unnecessarily large when using a single-stage Docker build.

Application

Node.js Hello World application:

console.log("Hello from Docker!");
Dockerfile
FROM node:22

WORKDIR /app

COPY app.js .

CMD ["node", "app.js"]
Build Image
docker build -t hello-node-single .
Run Container
docker run --rm hello-node-single

Output:

Hello from Docker!
Check Image Size
docker image ls

Output:

REPOSITORY          TAG       SIZE
hello-node-single   latest    1.1 GB

### TASK - 2

Objective

Reduce Docker image size by separating the build environment from the runtime environment using a multi-stage build.

Application
console.log("Hello from Docker!");
Multi-Stage Dockerfile
# Stage 1 - Build Stage
FROM node:22-alpine AS builder

WORKDIR /app

COPY app.js .

# Stage 2 - Runtime Stage
FROM alpine:latest

RUN apk add --no-cache nodejs

WORKDIR /app

COPY --from=builder /app/app.js .

CMD ["node", "app.js"]
Build Image
docker build -t hello-node-multistage .
Run Container
docker run --rm hello-node-multistage

Output:
Hello from Docker!

Why Is the Multi-Stage Image Smaller?

The build stage contains tools and dependencies required only during image creation. These files are not copied into the final image.

Only the application and the minimum runtime environment are included in the final stage.

As a result:

Smaller image size
Faster image transfers
Faster deployments
Reduced attack surface
Lower storage consumption


### TASK - 3

Objective

Learn how to publish Docker images to Docker Hub and verify they can be pulled and executed from another environment.

Local Image

Image used:

hello-node-multistage
Docker Login
docker login

Output:

Login Succeeded
Tag the Image
docker tag hello-node-multistage <dockerhub-username>/hello-node:v1

Example:

docker tag hello-node-multistage atharvak/hello-node:v1
Push the Image
docker push <dockerhub-username>/hello-node:v1

Example:

docker push atharvak/hello-node:v1
Verify Repository

Docker Hub Repository:

https://hub.docker.com/r/<dockerhub-username>/hello-node
Remove Local Image
docker rmi <dockerhub-username>/hello-node:v1
Pull Image Again
docker pull <dockerhub-username>/hello-node:v1
Run the Pulled Image
docker run --rm <dockerhub-username>/hello-node:v1

Output:

Hello from Docker!


### TASK - 4

Objective

Explore Docker Hub repositories, add repository documentation, and understand Docker image versioning using tags.

Repository Information

Repository:

<dockerhub-username>/hello-node

Description added:

A simple Node.js Docker application created for learning Docker image optimization, multi-stage builds, and Docker Hub workflows.
Exploring Tags

Available tags:

v1
latest

(Or any additional tags created.)

Pull a Specific Tag
docker pull <dockerhub-username>/hello-node:v1

Run:

docker run --rm <dockerhub-username>/hello-node:v1

Output:

Hello from Docker!
Pull Latest Tag
docker pull <dockerhub-username>/hello-node:latest

Run:

docker run --rm <dockerhub-username>/hello-node:latest

Output:

Hello from Docker!
Observations
Docker images can have multiple tags.
Each tag represents a specific version of an image.
The latest tag is the default tag when no tag is specified.
Pulling a specific tag ensures a predictable application version.

### TASK - 5

Objective

Optimize a Docker image by applying image best practices including smaller base images, non-root users, specific image tags, and reduced image layers.

Initial Dockerfile
FROM node:22

WORKDIR /app

COPY app.js .

CMD ["node", "app.js"]
Optimized Dockerfile
FROM node:22-alpine3.20

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

WORKDIR /app

COPY app.js .

USER appuser

CMD ["node", "app.js"]
Best Practices Applied
1. Minimal Base Image

Replaced:

FROM node:22

with:

FROM node:22-alpine3.20

Result: Smaller image size.

2. Non-Root User

Created a dedicated application user:

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

USER appuser

Result: Improved container security.

3. Combined RUN Commands

Used a single RUN instruction:

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

Result: Reduced image layers.

4. Specific Base Image Tag

Used:

node:22-alpine3.20

instead of:

node:latest

Result: Reproducible builds and predictable behavior.
