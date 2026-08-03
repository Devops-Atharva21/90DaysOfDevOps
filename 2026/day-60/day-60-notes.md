# Day 60 – Capstone: Deploy WordPress + MySQL on Kubernetes

## 🎯 Objective
Build a complete **WordPress + MySQL** application on Kubernetes by combining everything learned throughout the previous Kubernetes sessions.

---

# Expected Output

- ✅ WordPress + MySQL running inside the **capstone** namespace
- ✅ Self-healing verified
- ✅ Data persistence verified
- ✅ `day-60-capstone.md`
- ✅ Screenshot of:
  - Running WordPress website
  - `kubectl get all -n capstone`

---

# Task 1: Create the Namespace (Day 52)

### What you'll do
- Create a new namespace named **capstone**.
- Set it as the default namespace.

### Why?
Namespaces keep application resources organized and isolated from other projects.

### Commands
```bash
kubectl create namespace capstone

kubectl config set-context --current --namespace=capstone
```

### Verify
```bash
kubectl get ns
kubectl config view --minify
```

---

# Task 2: Deploy MySQL (Days 54–56)

### What you'll do
Deploy MySQL using:
- Secret
- Headless Service
- StatefulSet
- Persistent Storage

### Why?
- **Secret** stores database credentials securely.
- **Headless Service** provides stable DNS for StatefulSets.
- **StatefulSet** gives MySQL a fixed identity.
- **PVC** keeps database files safe after pod recreation.

### Requirements
- MySQL image: `mysql:8.0`
- Use `envFrom` for Secret
- Add CPU & Memory requests/limits
- Create a 1Gi Persistent Volume Claim

### Verify
Login into MySQL and list databases.

```bash
kubectl exec -it mysql-0 -- mysql -u <user> -p<password> -e "SHOW DATABASES;"
```

You should see:

```
wordpress
information_schema
mysql
performance_schema
```

---

# Task 3: Deploy WordPress (Days 52, 54, 57)

### What you'll do
Deploy WordPress using:
- ConfigMap
- Secret
- Deployment
- Resource limits
- Health probes

### Why?
- **ConfigMap** stores database host and database name.
- **Secret** stores database username/password.
- **Deployment** manages WordPress pods.
- **Probes** ensure the application is healthy and ready.

### Requirements
- 2 replicas
- Image: `wordpress:latest`
- Readiness Probe
- Liveness Probe
- Resource requests & limits

### Verify

```bash
kubectl get pods
```

Both WordPress pods should display:

```
2/2 Running
```

or

```
1/1 Running
```

(depending on the container count)

---

# Task 4: Expose WordPress (Day 53)

### What you'll do
Create a **NodePort Service** to access WordPress from your browser.

### Why?
Services expose applications running inside Kubernetes.

### Access

**Minikube**

```bash
minikube service wordpress -n capstone
```

**Kind**

```bash
kubectl port-forward svc/wordpress 8080:80 -n capstone
```

Open:

```
http://localhost:8080
```

Complete the WordPress installation and publish your first blog.

### Verify
The WordPress setup page should load successfully.

---

# Task 5: Test Self-Healing and Persistence

### What you'll do

Delete:
- one WordPress pod
- the MySQL pod

### Why?
This confirms Kubernetes automatically recreates failed pods and preserves stored data.

### Commands

Delete WordPress pod

```bash
kubectl delete pod <wordpress-pod-name>
```

Delete MySQL pod

```bash
kubectl delete pod mysql-0 -n capstone
```

### Verify

- WordPress pod is recreated automatically.
- MySQL pod is recreated.
- Your previously created blog post still exists.

---

# Task 6: Configure Horizontal Pod Autoscaler (Day 58)

### What you'll do
Create an HPA for the WordPress Deployment.

### Configuration

- CPU Target: **50%**
- Minimum Pods: **2**
- Maximum Pods: **10**

### Why?
HPA automatically increases or decreases pods based on CPU usage.

### Verify

```bash
kubectl get hpa -n capstone
```

Also check:

```bash
kubectl get all -n capstone
```

Confirm:
- Min replicas = 2
- Max replicas = 10
- CPU target = 50%

---

# Task 7: Bonus – Compare with Helm (Day 59)

### What you'll do
Deploy another WordPress application using Helm.

### Command

```bash
helm install wp-helm bitnami/wordpress
```

### Why?
Compare manual Kubernetes manifests with an automated Helm deployment.

Compare:
- Number of resources created
- Ease of deployment
- Flexibility and customization

After testing:

```bash
helm uninstall wp-helm
```

---

# Task 8: Clean Up and Reflect

### What you'll do

Review all resources:

```bash
kubectl get all -n capstone
```

Delete everything:

```bash
kubectl delete namespace capstone
```

Reset default namespace:

```bash
kubectl config set-context --current --namespace=default
```

### Verify

Run:

```bash
kubectl get ns
```

The **capstone** namespace should no longer exist.

---

# 📚 Kubernetes Concepts Used

This capstone combines almost every important Kubernetes concept:

- ✅ Namespace
- ✅ Secret
- ✅ ConfigMap
- ✅ Persistent Volume Claim (PVC)
- ✅ StatefulSet
- ✅ Headless Service
- ✅ Deployment
- ✅ NodePort Service
- ✅ Resource Requests & Limits
- ✅ Liveness Probe
- ✅ Readiness Probe
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ Helm

---

# 🎉 Summary

In this capstone project, you deployed a real **WordPress + MySQL** application using Kubernetes. Along the way, you practiced resource management, secure configuration, persistent storage, networking, health checks, autoscaling, and self-healing. Completing this project demonstrates how multiple Kubernetes components work together to run a production-like application.
