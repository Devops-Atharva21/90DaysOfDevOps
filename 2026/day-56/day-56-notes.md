# Day 56 – Kubernetes StatefulSets

## Task 1: Understand the Problem

### Deployment Manifest (`deployment.yaml`)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stateless-nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: stateless-web
  template:
    metadata:
      labels:
        app: stateless-web
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
```

### Verification & Commands
```bash
# Apply the deployment
kubectl apply -f deployment.yaml

# Check the generated pod names
kubectl get pods -l app=stateless-web

# Delete one of the pods
kubectl delete pod stateless-nginx-6748446b76-abc12

# Watch the replacement get a new random hash
kubectl get pods -l app=stateless-web
```

### Explanation
In this task, we deployed a standard stateless application to observe how Kubernetes handles dynamic scaling. Deployments are designed to scale rapidly by spinning up pods with random hash suffixes (e.g., `stateless-nginx-6748446b76-abc12`). When a pod is deleted, the ReplicaSet controller treats it as entirely ephemeral, replacing it with an entirely new pod name. 

**Verify:** *Why would random pod names be a problem for a database cluster?*  
Database clusters require strict leader election, data sharding, and replication protocols. If pod names and network identities change randomly during a failure, cluster peers cannot reliably locate each other, replication channels break, and distributed consensus mechanisms (like Raft or Paxos) will fail.

---

## Task 2: Create a Headless Service

### Headless Service Manifest (`service.yaml`)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: stateful-svc
spec:
  clusterIP: None  # .<service-name>.<namespace>.svc.cluster.local`. This means every single application replica now possesses a static network endpoint that clients can connect to explicitly.

**Verify:** *Does the nslookup IP match the pod IP?*  
**Yes.** The internal IP address returned by the `nslookup` command matches the precise IP address assigned to that individual pod under the `kubectl get pods -o wide` view.

---

## Task 5: Stable Storage — Data Survives Pod Deletion

### Verification & Commands
```bash
# Inject unique data into the volume of pod web-0
kubectl exec web-0 -- sh -c "echo 'Data from web-0' > /usr/share/nginx/html/index.html"

# Force delete the pod to test persistence mechanisms
kubectl delete pod web-0

# Wait for the controller to heal, then verify content
kubectl exec web-0 -- cat /usr/share/nginx/html/index.html
```

### Explanation
We verified the decoupling of storage from the pod life cycle. We wrote an ASCII string straight to the Nginx root directory inside `web-0` and subsequently deleted the pod. When the StatefulSet controller spun up a replacement pod, it matched the `web-0` identifier back to the existing `web-data-web-0` PVC, keeping the stored files intact without data corruption.

**Verify:** *Is the data identical after pod recreation?*  
**Yes.** The output remains exactly `"Data from web-0"`.

---

## Task 6: Ordered Scaling

### Verification & Commands
```bash
# Scale up the cluster state to 5 replicas
kubectl scale statefulset web --replicas=5
kubectl get pods -l app=stateful-web

# Scale back down to 3 replicas
kubectl scale statefulset web --replicas=3

# Review structural PVC allocations after downscaling
kubectl get pvc
```

### Explanation
We tested horizontal scaling mechanics. When scaling up, pods are provisioned sequentially (`web-3`, then `web-4`). When downscaling, the controller terminates pods in absolute reverse chronological order (`web-4` down first, then `web-3`). Crucially, Kubernetes avoids deleting the underlying PVCs during scale-down operations to protect your data.

**Verify:** *After scaling down, how many PVCs exist?*  
**5 PVCs** still exist (`web-data-web-0` through `web-data-web-4`).

---

## Task 7: Clean Up

### Verification & Commands
```bash
# Delete the workload controller and discovery network
kubectl delete statefulset web
kubectl delete svc stateful-svc

# Check residual PVC presence
kubectl get pvc

# Clean up persistent disk resources manually
kubectl delete pvc web-data-web-0 web-data-web-1 web-data-web-2 web-data-web-3 web-data-web-4
```

### Explanation
We safely scrubbed all cluster assets. Deleting a StatefulSet resource does not auto-terminate the storage claims it created. This design guardrail ensures that human errors or automation adjustments do not delete volumes holding active application state. We completed the task by manually cleaning up the storage disks.

**Verify:** *Were PVCs auto-deleted with the StatefulSet?*  
**No.** The PVCs remain active in the namespace until explicitly cleared by an administrator.

