# Day 52 – Kubernetes Namespaces and Deployments

## Overview

On Day 52, I learned how Kubernetes manages applications using **Namespaces** and **Deployments**.

Previously, I created standalone Pods, but they are not suitable for production because once a Pod is deleted, Kubernetes does not recreate it automatically.

Today I learned how Deployments solve this problem by maintaining the desired number of Pod replicas and automatically recovering failed Pods. I also explored Namespaces, which help organize and isolate resources inside a Kubernetes cluster.

---

# Objectives

- Understand Kubernetes built-in namespaces
- Create custom namespaces
- Deploy applications using Deployments
- Learn self-healing capability
- Scale Deployments
- Perform Rolling Updates and Rollbacks
- Clean up Kubernetes resources

---

# Expected Output

- ✅ Created multiple Kubernetes namespaces
- ✅ Deployed an application using Deployment
- ✅ Created multiple replicas
- ✅ Performed scaling operations
- ✅ Executed a Rolling Update
- ✅ Performed Rollback successfully
- ✅ Created this documentation
- ✅ Captured screenshots of Deployments and Pods

---

# Task 1 – Explore Default Namespaces

## Objective

Understand the default namespaces created by Kubernetes.

### Command

```bash
kubectl get namespaces
```

### Default Namespaces

| Namespace | Purpose |
|-----------|---------|
| default | Default namespace for user resources |
| kube-system | Contains Kubernetes control plane components |
| kube-public | Publicly readable resources |
| kube-node-lease | Stores node heartbeat information |

---

### Check System Pods

```bash
kubectl get pods -n kube-system
```

### What I Learned

- Kubernetes itself runs inside the `kube-system` namespace.
- Components like CoreDNS, kube-proxy, scheduler, etc., are managed here.
- These resources should never be modified unless necessary.

### Output

- Successfully listed all default namespaces.
- Verified the control plane Pods running inside `kube-system`.

---

# Task 2 – Create and Use Custom Namespaces

## Objective

Create separate environments for different applications.

### Create Namespaces

```bash
kubectl create namespace dev

kubectl create namespace staging
```

---

### Verify

```bash
kubectl get namespaces
```

---

### Create Namespace using YAML

**namespace.yaml**

```yaml
apiVersion: v1
kind: Namespace

metadata:
  name: production
```

Apply the manifest

```bash
kubectl apply -f namespace.yaml
```

---

### Create Pods inside Namespaces

```bash
kubectl run nginx-dev --image=nginx:latest -n dev

kubectl run nginx-staging --image=nginx:latest -n staging
```

---

### View Pods Across All Namespaces

```bash
kubectl get pods -A
```

---

### What I Learned

- Namespaces isolate Kubernetes resources.
- The same application can exist in multiple namespaces without conflicts.
- `kubectl get pods` only shows resources in the current namespace.
- `kubectl get pods -A` displays Pods from every namespace.

### Output

- Created **dev**, **staging**, and **production** namespaces.
- Successfully launched Pods in different namespaces.
- Verified Pods across all namespaces.

---

# Task 3 – Create the First Deployment

## Objective

Deploy an application using a Kubernetes Deployment.

---

### Deployment Manifest

**nginx-deployment.yaml**

```yaml
apiVersion: apps/v1

kind: Deployment

metadata:
  name: nginx-deployment
  namespace: dev
  labels:
    app: nginx

spec:
  replicas: 3

  selector:
    matchLabels:
      app: nginx

  template:
    metadata:
      labels:
        app: nginx

    spec:
      containers:
      - name: nginx
        image: nginx:1.24

        ports:
        - containerPort: 80
```

---

### Apply Deployment

```bash
kubectl apply -f nginx-deployment.yaml
```

---

### Verify Deployment

```bash
kubectl get deployments -n dev

kubectl get pods -n dev
```

---

### Deployment Columns

| Column | Meaning |
|---------|---------|
| READY | Number of healthy Pods |
| UP-TO-DATE | Pods updated with latest Deployment configuration |
| AVAILABLE | Pods available to serve traffic |

---

### What I Learned

Unlike standalone Pods, a Deployment continuously monitors the desired state and automatically recreates Pods if they fail.

### Output

- Successfully created Deployment.
- Kubernetes launched three Pod replicas automatically.

---

# Task 4 – Self-Healing

## Objective

Observe Kubernetes automatically replacing failed Pods.

---

### List Pods

```bash
kubectl get pods -n dev
```

---

### Delete One Pod

```bash
kubectl delete pod <pod-name> -n dev
```

---

### Check Again

```bash
kubectl get pods -n dev
```

---

### What I Learned

- The Deployment detected that one replica was missing.
- Kubernetes immediately created a new Pod.
- The replacement Pod had a **different name**, proving that a new Pod was created instead of restoring the old one.

### Output

- Verified Kubernetes self-healing capability.
- Deployment maintained the desired number of replicas automatically.

---

# Task 5 – Scale the Deployment

## Objective

Increase and decrease the number of application replicas.

---

### Scale Up

```bash
kubectl scale deployment nginx-deployment --replicas=5 -n dev
```

---

### Verify

```bash
kubectl get pods -n dev
```

---

### Scale Down

```bash
kubectl scale deployment nginx-deployment --replicas=2 -n dev
```

---

### Verify

```bash
kubectl get pods -n dev
```

---

### What I Learned

Scaling changes the number of running Pods without affecting the application.

- Scaling up creates new Pods.
- Scaling down removes extra Pods.

Kubernetes always maintains the desired replica count.

### Output

- Successfully scaled Deployment from **3 → 5 → 2** replicas.
- Observed Pods being created and terminated automatically.

---

# Task 6 – Rolling Update and Rollback

## Objective

Update the application without downtime and restore the previous version if needed.

---

### Update Image

```bash
kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev
```

---

### Watch Rollout

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

---

### View Rollout History

```bash
kubectl rollout history deployment/nginx-deployment -n dev
```

---

### Rollback

```bash
kubectl rollout undo deployment/nginx-deployment -n dev
```

---

### Verify Rollback

```bash
kubectl rollout status deployment/nginx-deployment -n dev
```

---

### Check Running Image

```bash
kubectl describe deployment nginx-deployment -n dev | grep Image
```

---

### What I Learned

Rolling Updates replace Pods gradually, ensuring zero downtime.

If something goes wrong, Kubernetes can instantly roll back to the previous working version.

### Output

- Successfully updated Nginx from **1.24 → 1.25**.
- Verified rollout status.
- Viewed rollout history.
- Rolled back successfully to the previous image version.

---

# Task 7 – Clean Up

## Objective

Remove all created Kubernetes resources.

---

### Delete Deployment

```bash
kubectl delete deployment nginx-deployment -n dev
```

---

### Delete Pods

```bash
kubectl delete pod nginx-dev -n dev

kubectl delete pod nginx-staging -n staging
```

---

### Delete Namespaces

```bash
kubectl delete namespace dev staging production
```

---

### Verify Cleanup

```bash
kubectl get namespaces

kubectl get pods -A
```

---

### What I Learned

Deleting a namespace removes every resource inside it, making cleanup simple but potentially destructive in production environments.

### Output

- Successfully removed all Deployments.
- Deleted Pods.
- Deleted custom namespaces.
- Verified that all resources were cleaned up.

---

# Key Concepts Learned

- Kubernetes Namespaces
- Namespace Isolation
- Deployment
- ReplicaSets
- Pod Templates
- Labels and Selectors
- Self-Healing
- Scaling Applications
- Rolling Updates
- Rollback
- Zero Downtime Deployment
- Resource Cleanup

---

# Important Commands Learned

```bash
kubectl get namespaces

kubectl create namespace dev

kubectl create namespace staging

kubectl apply -f namespace.yaml

kubectl run nginx-dev --image=nginx -n dev

kubectl get pods -A

kubectl apply -f nginx-deployment.yaml

kubectl get deployments -n dev

kubectl get pods -n dev

kubectl delete pod <pod-name> -n dev

kubectl scale deployment nginx-deployment --replicas=5 -n dev

kubectl set image deployment/nginx-deployment nginx=nginx:1.25 -n dev

kubectl rollout status deployment/nginx-deployment -n dev

kubectl rollout history deployment/nginx-deployment -n dev

kubectl rollout undo deployment/nginx-deployment -n dev

kubectl describe deployment nginx-deployment -n dev

kubectl delete deployment nginx-deployment -n dev

kubectl delete namespace dev staging production
```

---

# Summary

Day 52 introduced two of the most important Kubernetes concepts used in production environments: **Namespaces** and **Deployments**.

I learned how Namespaces organize cluster resources, while Deployments provide automatic Pod management, self-healing, scaling, and zero-downtime updates. These features make Kubernetes highly reliable for running modern containerized applications in real-world production environments.

---

# Screenshots

- `kubectl get namespaces`
- `kubectl get pods -A`
- `kubectl get deployments -n dev`
- `kubectl get pods -n dev`
- Scaling Deployment
- Rolling Update
- Rollback Status
- Final Cleanup Verification

---
