# Day 51 – Kubernetes Manifests and Your First Pods

## 📌 Task

Yesterday you set up a Kubernetes cluster. Today you'll deploy your first application using **Kubernetes manifests**. You'll learn how to write YAML manifest files and create **Pods**, the smallest deployable unit in Kubernetes.

By the end of this task, you should be able to write a Pod manifest from scratch without referring to the documentation.

---

# 🎯 Objectives

- Understand the structure of a Kubernetes manifest.
- Create and deploy Pods using YAML.
- Learn the difference between imperative and declarative approaches.
- Validate manifests before deployment.
- Work with Pod labels.
- Delete resources safely.

---

# ✅ Expected Output

- Three Pod manifests (`.yaml` files)
- `day-51-pods.md`
- Screenshot of running Pods (`kubectl get pods`)

---

# 📖 Anatomy of a Kubernetes Manifest

Every Kubernetes resource is defined using a YAML manifest.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: my-pod
  labels:
    app: my-app

spec:
  containers:
    - name: my-container
      image: nginx:latest
      ports:
        - containerPort: 80
```

## Understanding Each Field

| Field | Description |
|--------|-------------|
| **apiVersion** | Specifies which Kubernetes API version to use. Pods use `v1`. |
| **kind** | Defines the resource type (Pod, Deployment, Service, etc.). |
| **metadata** | Contains resource identity like name, namespace, and labels. |
| **spec** | Defines the desired state of the resource such as containers, images, ports, volumes, etc. |

---

# 🚀 Task 1 – Create Your First Pod (Nginx)

Create a file named **nginx-pod.yaml**

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: nginx-pod
  labels:
    app: nginx

spec:
  containers:
    - name: nginx
      image: nginx:latest
      ports:
        - containerPort: 80
```

### Apply the Manifest

```bash
kubectl apply -f nginx-pod.yaml
```

### Verify

```bash
kubectl get pods
kubectl get pods -o wide
```

Wait until the Pod status becomes **Running**.

---

### Explore the Pod

Describe the Pod

```bash
kubectl describe pod nginx-pod
```

View logs

```bash
kubectl logs nginx-pod
```

Open a shell inside the container

```bash
kubectl exec -it nginx-pod -- /bin/bash
```

Inside the container

```bash
curl localhost:80
exit
```

**Verification**

- Did you receive the default Nginx welcome page?

---

# 🚀 Task 2 – Create a BusyBox Pod

Create **busybox-pod.yaml**

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: busybox-pod
  labels:
    app: busybox
    environment: dev

spec:
  containers:
    - name: busybox
      image: busybox:latest
      command:
        - sh
        - -c
        - echo Hello from BusyBox && sleep 3600
```

Apply the manifest

```bash
kubectl apply -f busybox-pod.yaml
```

Verify

```bash
kubectl get pods
kubectl logs busybox-pod
```

### Why is the `command` field needed?

BusyBox doesn't run a long-lived application by default.

Without the `sleep` command:

- Container exits immediately
- Pod restarts continuously
- Eventually enters **CrashLoopBackOff**

**Verification**

```
Hello from BusyBox
```

should appear in the logs.

---

# 🚀 Task 3 – Imperative vs Declarative

## Declarative Approach

Write YAML first.

```bash
kubectl apply -f nginx-pod.yaml
```

## Imperative Approach

Create resources directly using commands.

```bash
kubectl run redis-pod --image=redis:latest
```

Verify

```bash
kubectl get pods
```

Generate the YAML of the created Pod

```bash
kubectl get pod redis-pod -o yaml
```

Notice Kubernetes automatically adds

- UID
- Resource Version
- Status
- Creation Timestamp
- Managed Fields

---

## Generate YAML Without Creating Resources

```bash
kubectl run test-pod \
--image=nginx \
--dry-run=client \
-o yaml
```

This is a quick way to scaffold manifests before customizing them.

---

# 🚀 Task 4 – Validate Before Applying

Client-side validation

```bash
kubectl apply -f nginx-pod.yaml --dry-run=client
```

Server-side validation

```bash
kubectl apply -f nginx-pod.yaml --dry-run=server
```

### Practice

Remove the `image` field or introduce an invalid field and run validation again.

Observe the validation error returned by Kubernetes.

---

# 🚀 Task 5 – Pod Labels

Labels organize Kubernetes resources.

View labels

```bash
kubectl get pods --show-labels
```

Filter Pods

```bash
kubectl get pods -l app=nginx

kubectl get pods -l environment=dev
```

Add a label

```bash
kubectl label pod nginx-pod environment=production
```

Verify

```bash
kubectl get pods --show-labels
```

Remove the label

```bash
kubectl label pod nginx-pod environment-
```

### Challenge

Create another Pod with three labels

```yaml
labels:
  app: demo
  environment: dev
  team: backend
```

Practice filtering using different label combinations.

---

# 🚀 Task 6 – Clean Up

Delete individual Pods

```bash
kubectl delete pod nginx-pod

kubectl delete pod busybox-pod

kubectl delete pod redis-pod
```

Delete using the manifest

```bash
kubectl delete -f nginx-pod.yaml
```

Verify

```bash
kubectl get pods
```

---

# 📌 Important Note

Standalone Pods are **not self-healing**.

If you delete them, Kubernetes does **not** recreate them.

Production environments use **Deployments**, which automatically recreate Pods if they fail or are deleted.

You'll learn about Deployments in **Day 52**.

---

# 📝 What I Learned

- Kubernetes resources are defined using YAML manifests.
- Every manifest contains `apiVersion`, `kind`, `metadata`, and `spec`.
- Pods are the smallest deployable units in Kubernetes.
- `kubectl apply` follows the declarative approach.
- `kubectl run` follows the imperative approach.
- `--dry-run` helps generate and validate manifests safely.
- Labels help organize and filter Kubernetes resources.
- Standalone Pods are temporary and should not be used in production.

---

# 📚 Common kubectl Commands

```bash
kubectl apply -f file.yaml

kubectl get pods

kubectl get pods -o wide

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl exec -it <pod-name> -- /bin/bash

kubectl get pod <pod-name> -o yaml

kubectl get pods --show-labels

kubectl get pods -l app=nginx

kubectl label pod <pod-name> environment=production

kubectl delete pod <pod-name>

kubectl delete -f file.yaml
```

---

# 🎯 Key Takeaways

- Pods are the foundation of Kubernetes workloads.
- YAML manifests provide a reproducible and version-controlled way to manage resources.
- Declarative configuration is the preferred approach in real-world Kubernetes environments.
- Always validate manifests before applying them.
- Labels are essential for organizing, selecting, and managing Kubernetes resources.
- Bare Pods are mainly for learning and testing—Deployments should be used in production.
