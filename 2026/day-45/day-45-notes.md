# Day 45 - Docker Publish with GitHub Actions

## Objective

Automate Docker image building and publishing using GitHub Actions. Learn how to build Docker images in CI, push them to Docker Hub, tag images, and display workflow status with a badge.

---

# Task 1: Prepare

### Requirements

- Use the application you Dockerized on **Day 36** (or any simple Docker application).
- Add the `Dockerfile` to your **github-actions-practice** repository.
- Make sure the following GitHub Secrets are already configured (from Day 44):
  - `DOCKER_USERNAME`
  - `DOCKER_TOKEN`

### Example Dockerfile

```dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html

EXPOSE 80
```

---

# Task 2: Build the Docker Image in CI

Create the workflow:

```
.github/workflows/docker-publish.yml
```

### Workflow

```yaml
name: Docker Publish

on:
  push:
    branches:
      - main

jobs:
  docker:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Build Docker Image
        run: |
          docker build -t my-app .
```

### Verify

Go to:

**GitHub → Actions → Docker Publish**

Check the logs.

Expected output:

```
Successfully built <image-id>
Successfully tagged my-app:latest
```

---

# Task 3: Push to Docker Hub

Update the workflow to:

- Login to Docker Hub
- Tag the image
- Push two tags
  - latest
  - sha-<short-commit-hash>

## Complete Workflow

```yaml
name: Docker Publish

on:
  push:
    branches:
      - main

jobs:
  docker:
    runs-on: ubuntu-latest

    env:
      IMAGE_NAME: ${{ secrets.DOCKER_USERNAME }}/github-actions-practice

    steps:
      - uses: actions/checkout@v4

      - name: Build Image
        run: docker build -t my-app .

      - name: Login to Docker Hub
        run: |
          echo "${{ secrets.DOCKER_TOKEN }}" | docker login \
          -u "${{ secrets.DOCKER_USERNAME }}" \
          --password-stdin

      - name: Tag Image
        run: |
          SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)

          docker tag my-app $IMAGE_NAME:latest
          docker tag my-app $IMAGE_NAME:sha-$SHORT_SHA

      - name: Push Images
        run: |
          SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)

          docker push $IMAGE_NAME:latest
          docker push $IMAGE_NAME:sha-$SHORT_SHA
```

### Verify

Visit your Docker Hub repository.

You should see two image tags:

```
latest

sha-abc1234
```

---

# Task 4: Only Push on Main

Modify the push step so it only runs on the **main** branch.

```yaml
- name: Push Images
  if: github.ref == 'refs/heads/main'
  run: |
    SHORT_SHA=$(echo $GITHUB_SHA | cut -c1-7)

    docker push $IMAGE_NAME:latest
    docker push $IMAGE_NAME:sha-$SHORT_SHA
```

### Test

Create a feature branch.

```bash
git checkout -b feature/test
```

Commit and push.

Expected:

- ✅ Image builds
- ❌ Image is NOT pushed

---

# Task 5: Add a Status Badge

Go to:

```
GitHub Repository
    ↓
Actions
    ↓
Docker Publish Workflow
    ↓
...
    ↓
Create Status Badge
```

Copy the Markdown.

Example:

```md
![Docker Publish](https://github.com/USERNAME/REPO/actions/workflows/docker-publish.yml/badge.svg)
```

Add it to your `README.md`.

Example:

```md
# GitHub Actions Practice

![Docker Publish](https://github.com/USERNAME/REPO/actions/workflows/docker-publish.yml/badge.svg)
```

Push the changes.

The badge should become:

🟢 Passing

---

# Task 6: Pull and Run It

Pull the image from Docker Hub.

```bash
docker pull username/github-actions-practice:latest
```

Run the container.

```bash
docker run -d -p 8080:80 username/github-actions-practice:latest
```

Open:

```
http://localhost:8080
```

If your application loads, everything worked successfully.

---

# Full Journey (Git Push → Running Container)

```
Developer
    │
    ▼
git push
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Actions Triggered
    │
    ▼
Checkout Source Code
    │
    ▼
Build Docker Image
    │
    ▼
Login to Docker Hub
    │
    ▼
Tag Image
    │
    ▼
Push Image
    │
    ▼
Docker Hub Repository
    │
    ▼
docker pull
    │
    ▼
docker run
    │
    ▼
Running Container
```

---

# Key GitHub Actions Concepts Learned

- Docker image build automation
- Docker Hub authentication using GitHub Secrets
- Image tagging (`latest` and commit SHA)
- Conditional workflow execution
- Publishing Docker images from CI/CD
- Workflow status badges
- Pulling and running published images

---

# Commands Cheat Sheet

## Build Image

```bash
docker build -t my-app .
```

## Login

```bash
docker login
```

## Tag

```bash
docker tag my-app username/github-actions-practice:latest
```

```bash
docker tag my-app username/github-actions-practice:sha-abc1234
```

## Push

```bash
docker push username/github-actions-practice:latest
```

```bash
docker push username/github-actions-practice:sha-abc1234
```

## Pull

```bash
docker pull username/github-actions-practice:latest
```

## Run

```bash
docker run -d -p 8080:80 username/github-actions-practice:latest
```

---

# Summary

By completing these tasks, you learned how to:

- Build Docker images automatically using GitHub Actions.
- Authenticate securely with Docker Hub using GitHub Secrets.
- Push versioned Docker images.
- Restrict publishing to the main branch.
- Display workflow status using badges.
- Deploy a container by pulling the published image from Docker Hub.
