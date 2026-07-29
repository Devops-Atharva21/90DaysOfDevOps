# Day 58 – Metrics Server & Horizontal Pod Autoscaler (HPA)

## 🎯 Objective
Today you'll enable the **Metrics Server** so Kubernetes can monitor CPU and memory usage, then configure a **Horizontal Pod Autoscaler (HPA)** to automatically increase or decrease the number of Pods based on CPU utilization.

---

# 📚 What You'll Learn

- Install the Metrics Server
- Monitor resource usage with `kubectl top`
- Create an HPA
- Generate CPU load to test autoscaling
- Configure HPA using YAML
- Understand HPA scaling behavior

---

# Task 1: Install the Metrics Server

## 🎯 Goal
Install the Metrics Server so Kubernetes can collect CPU and memory usage from nodes and pods.

### Check if it's already installed

```bash
kubectl get pods -n kube-system | grep metrics-server
```

### Install

**Minikube**

```bash
minikube addons enable metrics-server
```

**Kind / kubeadm**

Apply the official Metrics Server manifest from GitHub.

> **Note:** Local clusters may require the `--kubelet-insecure-tls` flag. Never use this in production.

### Verify

Wait about 60 seconds, then run:

```bash
kubectl top nodes
kubectl top pods -A
```

### ✅ Quick Explanation

- Metrics Server collects CPU and memory usage.
- `kubectl top` only works after Metrics Server is installed.
- Without it, HPA cannot make scaling decisions.

---

# Task 2: Explore kubectl top

## 🎯 Goal
View real-time resource usage.

### Commands

```bash
kubectl top nodes

kubectl top pods -A

kubectl top pods -A --sort-by=cpu
```

### ✅ Quick Explanation

- Shows **actual CPU and memory usage**.
- Does **not** display Requests or Limits.
- Metrics are refreshed every **15 seconds**.

---

# Task 3: Create a Deployment with CPU Requests

## 🎯 Goal
Deploy an application that HPA can monitor.

Use the image:

```
registry.k8s.io/hpa-example
```

Set:

```yaml
resources:
  requests:
    cpu: 200m
```

Expose it:

```bash
kubectl expose deployment php-apache --port=80
```

### ✅ Quick Explanation

- HPA calculates CPU utilization using **CPU Requests**.
- Without CPU requests, HPA will not work.
- This is one of the most common HPA configuration mistakes.

---

# Task 4: Create an HPA (Imperative)

## 🎯 Goal
Automatically scale the Deployment based on CPU usage.

Create HPA:

```bash
kubectl autoscale deployment php-apache \
--cpu-percent=50 \
--min=1 \
--max=10
```

Verify:

```bash
kubectl get hpa

kubectl describe hpa php-apache
```

### ✅ Quick Explanation

- Scale up when average CPU usage goes above **50%**.
- Scale down when CPU drops below **50%**.
- Initially, the **TARGETS** column may show `<unknown>` until metrics become available.

---

# Task 5: Generate Load and Watch Autoscaling

## 🎯 Goal
Increase CPU usage and watch HPA add more Pods.

Create a load generator:

```bash
kubectl run load-generator \
--image=busybox:1.36 \
--restart=Never \
-- /bin/sh -c "while true; do wget -q -O- http://php-apache; done"
```

Watch HPA:

```bash
kubectl get hpa php-apache --watch
```

Delete the load generator:

```bash
kubectl delete pod load-generator
```

### ✅ Quick Explanation

- The load generator continuously sends requests.
- CPU usage increases.
- HPA creates additional Pods automatically.
- Scale down is intentionally slower (about 5 minutes).

---

# Task 6: Create an HPA using YAML (Declarative)

## 🎯 Goal
Manage HPA using a YAML manifest instead of commands.

Delete the old HPA:

```bash
kubectl delete hpa php-apache
```

Create a new HPA using:

- `autoscaling/v2`
- CPU target: **50%**
- Scale-up behavior
- Scale-down stabilization window: **300 seconds**

Apply:

```bash
kubectl apply -f hpa.yaml
```

Verify:

```bash
kubectl describe hpa php-apache
```

### ✅ Quick Explanation

`autoscaling/v2` provides advanced features like:

- Multiple metrics
- Custom scaling policies
- Scale-up rules
- Scale-down stabilization
- Better control over autoscaling

---

# Task 7: Clean Up

Delete the resources:

```bash
kubectl delete hpa php-apache

kubectl delete service php-apache

kubectl delete deployment php-apache

kubectl delete pod load-generator
```

Leave the **Metrics Server** installed for future labs.

### ✅ Quick Explanation

Cleaning up removes unnecessary resources while keeping Metrics Server available for future HPA exercises.

---

# 📝 Important Notes

- Metrics Server is required for HPA.
- `kubectl top` shows **actual usage**, not Requests or Limits.
- HPA calculates CPU utilization using **CPU Requests**.
- Always define CPU Requests when using HPA.
- HPA does not instantly scale down to avoid frequent fluctuations.
- `autoscaling/v2` offers more flexibility than imperative commands.

---

# 🔑 Key Takeaways

- Metrics Server provides CPU and memory metrics.
- `kubectl top` displays live resource usage.
- HPA automatically scales Pods based on CPU utilization.
- CPU Requests are mandatory for HPA.
- Load testing helps verify autoscaling.
- Declarative HPA (`autoscaling/v2`) supports advanced scaling behavior.
- Scale-up is fast, while scale-down is intentionally delayed for stability.

---

# ✅ Expected Outcome

After completing Day 58, you should have:

- ✔ Metrics Server installed
- ✔ `kubectl top` showing resource usage
- ✔ Deployment with CPU requests
- ✔ HPA created and working
- ✔ Automatic scaling under load
- ✔ Declarative HPA using `autoscaling/v2`
- ✔ Understanding of HPA scaling behavior
