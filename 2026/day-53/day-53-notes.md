# Day 53 – Kubernetes Services

## Objective
Learn how Kubernetes Services provide a stable network endpoint for Pods and expose applications internally and externally.

## Why Services?
Pods receive dynamic IPs that change when recreated. A Service provides:
- Stable virtual IP (ClusterIP)
- Stable DNS name
- Load balancing across matching Pods

```
Client
  |
Service (Stable IP)
 |-- Pod 1
 |-- Pod 2
 `-- Pod 3
```

## Expected Output
- Deployment exposed using ClusterIP, NodePort and LoadBalancer
- Verified Pod-to-Service communication
- `day-53-services.md`
- Screenshot of `kubectl get services`

---

# Task 1 – Deploy the Application
Create a Deployment with **3 Nginx replicas**.

**Purpose**
- Creates multiple identical Pods.
- Demonstrates why Services are needed because Pod IPs are temporary.

Apply:
```bash
kubectl apply -f app-deployment.yaml
kubectl get pods -o wide
```

Verify:
- 3 Pods are Running.
- Observe different Pod IPs.

---

# Task 2 – ClusterIP Service
ClusterIP is the **default Service type**.

**Purpose**
- Internal communication only.
- Assigns a stable virtual IP.
- Load balances traffic to Pods.

Key fields:
- `selector` → selects Pods.
- `port` → Service port.
- `targetPort` → Container port.

Test:
```bash
kubectl run test-client --image=busybox --rm -it --restart=Never -- sh
wget -qO- http://web-app-clusterip
```

Verify:
- Nginx page appears.
- Service works even if Pod IPs change.

---

# Task 3 – Service Discovery using DNS
Every Service automatically receives a DNS name.

Formats:
- Short: `web-app-clusterip`
- Full: `web-app-clusterip.default.svc.cluster.local`

Commands:
```bash
nslookup web-app-clusterip
wget -qO- http://web-app-clusterip
```

Verify:
- DNS resolves to the ClusterIP.
- Short and full names return the same application.

---

# Task 4 – NodePort Service
NodePort exposes the Service outside the cluster.

Traffic Flow:
```
Browser
   |
NodeIP:30080
   |
NodePort Service
   |
Pods
```

Range:
- `30000–32767`

Access:
- Minikube: `minikube service web-app-nodeport --url`
- Docker Desktop: `http://localhost:30080`
- Kind: `curl <NodeIP>:30080`

Verify:
- Nginx page opens externally.

---

# Task 5 – LoadBalancer Service
Used mainly in cloud environments.

Purpose:
- Creates an external cloud load balancer.
- Routes internet traffic to the Service.

Local Clusters:
- EXTERNAL-IP remains `<pending>`.
- Minikube supports simulation using:
```bash
minikube tunnel
```

Verify:
- Cloud → Public IP assigned.
- Local → `<pending>` is expected.

---

# Task 6 – Compare Service Types

| Type | Access | Use Case |
|------|--------|----------|
| ClusterIP | Inside cluster | Internal communication |
| NodePort | `<NodeIP>:Port` | Development & Testing |
| LoadBalancer | Public IP | Production |

Relationship:
```
LoadBalancer
      |
  NodePort
      |
  ClusterIP
      |
     Pods
```

Check:
```bash
kubectl get services -o wide
kubectl describe service web-app-loadbalancer
```

Verify that the LoadBalancer Service also has a ClusterIP and NodePort.

---

# Key Takeaways
- Pods have temporary IPs.
- Services provide stable networking.
- ClusterIP is internal.
- NodePort exposes via every node.
- LoadBalancer exposes through a cloud provider.
- Kubernetes DNS enables Service discovery without hardcoding IP addresses.

