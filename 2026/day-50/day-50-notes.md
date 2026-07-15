# Day 50 – Kubernetes Architecture and Cluster Setup

## 📖 Overview
Today I started my Kubernetes journey by learning how Kubernetes manages containers across multiple machines. I understood the Kubernetes architecture, installed the required tools, created my first local Kubernetes cluster using **Kind**, and explored the cluster using basic `kubectl` commands.

---

# ✅ Task 1: Recall the Kubernetes Story

## What I Learned

### Why was Kubernetes created?
Docker can run containers on a single machine, but managing hundreds of containers across multiple servers becomes difficult.

Kubernetes was created to:
- Automate container deployment
- Scale applications automatically
- Recover failed containers
- Load balance traffic
- Manage applications across multiple servers

### Who created Kubernetes?
- Created by **Google**
- Inspired by Google's internal container management system called **Borg**
- Now maintained by the **Cloud Native Computing Foundation (CNCF)**

### What does Kubernetes mean?
Kubernetes is a Greek word meaning **"Helmsman"** or **"Pilot"**, which represents steering and managing containerized applications.

### ✅ What I Did
- Wrote down what I remembered before checking the documentation.
- Verified my understanding using the official Kubernetes documentation.

---

# ✅ Task 2: Kubernetes Architecture

## Kubernetes Architecture

```
                 kubectl
                    |
                    ▼
              API Server
          ┌────────┼────────┐
          │        │        │
        etcd   Scheduler  Controller Manager
                    |
                    ▼
             Worker Node
      ┌────────────────────────┐
      │ kubelet                │
      │ kube-proxy             │
      │ Container Runtime      │
      │        Pods            │
      └────────────────────────┘
```

## Control Plane Components

### API Server
- Entry point of the cluster
- Receives all kubectl commands

### etcd
- Stores cluster configuration and state
- Acts as the cluster database

### Scheduler
- Decides where new Pods should run

### Controller Manager
- Ensures the actual cluster state matches the desired state

---

## Worker Node Components

### kubelet
- Runs on every node
- Creates and manages Pods

### kube-proxy
- Handles networking between Pods

### Container Runtime
- Runs the containers
- Example: containerd

---

## What happens when `kubectl apply -f pod.yaml` is executed?

1. kubectl sends the request to the API Server.
2. API Server stores the desired state in etcd.
3. Scheduler selects the best worker node.
4. kubelet receives instructions.
5. Container Runtime starts the Pod.
6. Controller Manager continuously checks that the Pod stays healthy.

---

## What happens if the API Server goes down?

- kubectl commands stop working.
- No new resources can be created.
- Existing Pods continue running.

---

## What happens if a Worker Node goes down?

- Pods on that node become unavailable.
- Controller Manager detects the failure.
- Scheduler creates replacement Pods on healthy nodes.

---

### ✅ What I Did
- Studied each Kubernetes component.
- Understood how requests travel through the cluster.
- Learned the responsibilities of the Control Plane and Worker Nodes.

---

# ✅ Task 3: Install kubectl

## Installation

Installed **kubectl** on Ubuntu.

Verified installation using:

```bash
kubectl version --client
```

### ✅ What I Did
- Installed kubectl successfully.
- Verified the client version.

---

# ✅ Task 4: Set Up Local Kubernetes Cluster

## Tool Chosen

**Kind (Kubernetes in Docker)**

### Why I chose Kind

- Lightweight
- Easy to install
- Perfect for learning Kubernetes
- Uses Docker containers as Kubernetes nodes

## Create Cluster

```bash
kind create cluster --name devops-cluster
```

## Verify Cluster

```bash
kubectl cluster-info

kubectl get nodes
```

### ✅ What I Did
- Installed Kind.
- Created my first Kubernetes cluster.
- Verified the cluster was running successfully.

---

# ✅ Task 5: Explore the Cluster

## Commands Practiced

### Cluster Information

```bash
kubectl cluster-info
```

### List Nodes

```bash
kubectl get nodes
```

### Describe Node

```bash
kubectl describe node <node-name>
```

### List Namespaces

```bash
kubectl get namespaces
```

### List All Pods

```bash
kubectl get pods -A
```

### View System Pods

```bash
kubectl get pods -n kube-system
```

## What I Observed

I found several important Kubernetes components running inside the `kube-system` namespace:

- kube-apiserver
- etcd
- kube-scheduler
- kube-controller-manager
- kube-proxy
- CoreDNS

These components matched the architecture I learned earlier.

### ✅ What I Did
- Explored the Kubernetes cluster.
- Viewed nodes, namespaces, and Pods.
- Matched the running system Pods with Kubernetes architecture components.

---

# ✅ Task 6: Practice Cluster Lifecycle

## Delete Cluster

```bash
kind delete cluster --name devops-cluster
```

## Recreate Cluster

```bash
kind create cluster --name devops-cluster
```

## Verify

```bash
kubectl get nodes
```

---

## Useful kubectl Commands

### Current Context

```bash
kubectl config current-context
```

### Available Contexts

```bash
kubectl config get-contexts
```

### View kubeconfig

```bash
kubectl config view
```

---

## What is kubeconfig?

`kubeconfig` is a configuration file that stores:

- Cluster information
- User credentials
- Contexts
- Connection details

It tells kubectl which Kubernetes cluster to communicate with.

### Default Location

**Linux**

```text
~/.kube/config
```

**Windows**

```text
C:\Users\<username>\.kube\config
```

---

### ✅ What I Did
- Deleted the cluster.
- Recreated the cluster successfully.
- Learned how kubeconfig manages cluster connections.
- Explored Kubernetes contexts.

---

# 📸 Expected Output

- ✅ Installed kubectl
- ✅ Installed Kind
- ✅ Created a local Kubernetes cluster
- ✅ Verified cluster health using `kubectl get nodes`
- ✅ Explored namespaces and Pods
- ✅ Understood Kubernetes architecture
- ✅ Practiced deleting and recreating the cluster
- ✅ Learned about kubeconfig and cluster contexts

---

# 📝 Key Takeaways

- Kubernetes is a container orchestration platform.
- The Control Plane manages the cluster.
- Worker Nodes run applications inside Pods.
- `kubectl` is the command-line tool to communicate with the cluster.
- Kind creates a local Kubernetes cluster using Docker.
- Most Kubernetes system components run inside the `kube-system` namespace.
- kubeconfig stores the connection information for Kubernetes clusters.

---
**Day 50 Complete ✅**
