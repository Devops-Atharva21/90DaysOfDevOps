# Day 57 – Kubernetes Resource Requests, Limits, and Probes

## 📌 Objective

Today I learned how Kubernetes manages Pod resources and monitors application health using **Resource Requests**, **Resource Limits**, and **Health Probes**.

By the end of this lab, I was able to:

- Configure CPU and Memory Requests & Limits
- Understand Kubernetes QoS (Quality of Service) Classes
- Observe an **OOMKilled** container
- Understand why Pods remain in the **Pending** state
- Configure and test **Liveness Probe**
- Configure and test **Readiness Probe**
- Configure and test **Startup Probe**

---

# Task 1: Resource Requests and Limits

## What I Did

Created a Pod manifest and defined CPU and Memory Requests and Limits.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "250m"
    memory: "256Mi"
```

Applied the manifest:

```bash
kubectl apply -f pod.yaml
```

Verified the configuration:

```bash
kubectl describe pod resource-demo
```

---

## What I Learned

### Resource Requests

Requests tell the Kubernetes Scheduler the **minimum resources** required by a Pod.

If a node cannot satisfy these requests, the Pod will not be scheduled on that node.

```
CPU Request = 100m (0.1 CPU)

Memory Request = 128Mi
```

---

### Resource Limits

Limits define the **maximum amount of resources** a container can consume.

If the container exceeds:

- CPU → Kubernetes throttles CPU usage.
- Memory → Kubernetes terminates the container (OOMKilled).

```
CPU Limit = 250m

Memory Limit = 256Mi
```

---

### QoS (Quality of Service)

Kubernetes automatically assigns a QoS Class.

There are three QoS classes:

| QoS Class | Condition |
|-----------|-----------|
| Guaranteed | Requests = Limits |
| Burstable | Requests < Limits |
| BestEffort | No Requests or Limits |

Since my Requests and Limits were different,

**QoS Class = Burstable**

Verified using:

```bash
kubectl describe pod
```

---

# Task 2: OOMKilled (Out of Memory)

## What I Did

Created a Pod using the **polinux/stress** image.

Configured a memory limit of **100Mi**.

Then forced the container to allocate **200MB** of RAM.

```yaml
command: ["stress"]

args:
- "--vm"
- "1"
- "--vm-bytes"
- "200M"
- "--vm-hang"
- "1"
```

Applied the Pod.

```bash
kubectl apply -f stress.yaml
```

Checked Pod status.

```bash
kubectl get pods
```

Described the Pod.

```bash
kubectl describe pod stress
```

---

## What Happened

The container immediately exceeded its memory limit.

Kubernetes terminated the container.

The Pod entered a CrashLoopBackOff state.

Inside Events I observed:

```
Reason: OOMKilled

Exit Code: 137
```

---

## What I Learned

Unlike CPU, memory cannot be throttled.

When a container crosses its memory limit, Linux immediately kills the process.

```
OOMKilled Exit Code = 137

128 + SIGKILL (9)
```

---

# Task 3: Pending Pod

## What I Did

Created a Pod requesting unrealistic resources.

```yaml
requests:
  cpu: "100"
  memory: "128Gi"
```

Applied the Pod.

```bash
kubectl apply -f pending.yaml
```

Checked Pod status.

```bash
kubectl get pods
```

The Pod remained in:

```
Pending
```

Checked scheduler events.

```bash
kubectl describe pod pending-pod
```

---

## What I Learned

The Kubernetes Scheduler could not find any node capable of satisfying the requested resources.

Inside Events I observed messages similar to:

```
0/1 nodes are available:
Insufficient cpu
Insufficient memory
```

This helped me understand how Kubernetes schedules workloads based on resource availability.

---

# Task 4: Liveness Probe

## What I Did

Created a BusyBox Pod.

On startup it created a file:

```
/tmp/healthy
```

After 30 seconds it deleted that file.

Configured an Exec Liveness Probe.

```yaml
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy

  periodSeconds: 5
  failureThreshold: 3
```

Applied the Pod.

```bash
kubectl apply -f liveness.yaml
```

Watched the Pod.

```bash
kubectl get pods -w
```

---

## What Happened

Initially:

```
Probe Passed
```

After the file was deleted:

```
Probe Failed
```

After three consecutive failures:

Kubernetes restarted the container automatically.

Verified using:

```bash
kubectl describe pod
```

or

```bash
kubectl get pod
```

Restart count increased.

---

## What I Learned

A Liveness Probe determines whether the application is still alive.

If it repeatedly fails,

Kubernetes restarts the container automatically.

---

# Task 5: Readiness Probe

## What I Did

Created an Nginx Pod.

Configured an HTTP Readiness Probe.

```yaml
readinessProbe:
  httpGet:
    path: /
    port: 80
```

Created a Service.

```bash
kubectl expose pod readiness-pod \
--port=80 \
--name=readiness-svc
```

Verified endpoints.

```bash
kubectl get endpoints readiness-svc
```

The Pod IP appeared inside the endpoint list.

Then intentionally broke the application.

```bash
kubectl exec readiness-pod -- rm /usr/share/nginx/html/index.html
```

Waited approximately 15 seconds.

Checked Pod readiness.

```bash
kubectl get pods
```

Checked endpoints again.

```bash
kubectl get endpoints readiness-svc
```

---

## What Happened

The Pod became:

```
0/1 READY
```

The Service endpoint list became empty.

However,

The container continued running.

It was **NOT restarted**.

---

## What I Learned

Readiness Probes determine whether a Pod is ready to receive traffic.

When the probe fails:

- Pod is removed from Service endpoints
- No new traffic reaches the Pod
- Container is NOT restarted

---

# Task 6: Startup Probe

## What I Did

Created a container that simulated a slow startup.

The container waited 20 seconds before creating:

```
/tmp/started
```

Configured a Startup Probe.

```yaml
startupProbe:
  exec:
    command:
    - cat
    - /tmp/started

  periodSeconds: 5
  failureThreshold: 12
```

Also configured a Liveness Probe checking the same file.

Applied the Pod.

```bash
kubectl apply -f startup.yaml
```

---

## What Happened

During startup,

Only the Startup Probe executed.

Liveness and Readiness Probes remained disabled.

After approximately 20 seconds,

Startup Probe succeeded.

Only then did Kubernetes begin running Liveness and Readiness Probes.

---

## What I Learned

Startup Probes are useful for applications that require a long initialization time.

Without a Startup Probe,

the Liveness Probe might incorrectly assume the application has failed and continuously restart it.

If I changed:

```
failureThreshold = 2
```

with

```
periodSeconds = 5
```

The Startup Probe would fail after only 10 seconds.

Since my application required around 20 seconds to start,

Kubernetes would repeatedly restart the container before it ever became healthy.

---

# Key Concepts Learned

| Concept | Purpose |
|----------|---------|
| Requests | Minimum resources guaranteed for scheduling |
| Limits | Maximum resources allowed during runtime |
| QoS Class | Determines Pod priority during resource pressure |
| OOMKilled | Container killed for exceeding memory limit |
| Pending Pod | Scheduler cannot find sufficient resources |
| Liveness Probe | Restarts unhealthy containers |
| Readiness Probe | Controls whether a Pod receives traffic |
| Startup Probe | Gives slow-starting applications enough time to initialize |

---

# Commands Used

```bash
kubectl apply -f <file>.yaml

kubectl get pods

kubectl get pods -w

kubectl describe pod <pod-name>

kubectl logs <pod-name>

kubectl exec -it <pod-name> -- sh

kubectl expose pod <pod-name> --port=80 --name=<service-name>

kubectl get endpoints

kubectl delete -f <file>.yaml
```

---

# Key Takeaways

- Requests help Kubernetes schedule Pods efficiently.
- Limits prevent containers from consuming excessive resources.
- Memory limit violations result in **OOMKilled (Exit Code 137)**.
- Pods remain in **Pending** if requested resources are unavailable.
- Liveness Probes automatically restart failed applications.
- Readiness Probes remove unhealthy Pods from Service traffic without restarting them.
- Startup Probes protect slow-starting applications from premature restarts.
- Proper resource management and health checks are essential for running reliable production workloads in Kubernetes.
