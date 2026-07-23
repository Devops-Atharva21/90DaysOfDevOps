# Day 55 – Persistent Volumes (PV) and Persistent Volume Claims (PVC)

## Objective

Containers are **ephemeral**, meaning any data stored inside a Pod is lost when the Pod is deleted. Kubernetes solves this problem using **Persistent Volumes (PV)** and **Persistent Volume Claims (PVC)**, allowing applications to retain data even after Pods restart.

---

# Key Concepts

## Persistent Volume (PV)

A **Persistent Volume (PV)** is a piece of storage in the Kubernetes cluster that has been provisioned by an administrator or dynamically created using a StorageClass.

### Interview Definition

> A Persistent Volume (PV) is a cluster-level storage resource that provides persistent data storage independent of a Pod's lifecycle.

---

## Persistent Volume Claim (PVC)

A **Persistent Volume Claim (PVC)** is a request for storage made by a user. Kubernetes automatically binds a matching PV to the PVC.

### Interview Definition

> A Persistent Volume Claim (PVC) is a request for persistent storage that allows Pods to use storage without knowing how it is provisioned.

---

## StorageClass

A **StorageClass** defines **how Kubernetes should automatically create PersistentVolumes**.

### Interview Definition

> A StorageClass is a Kubernetes resource that enables dynamic provisioning by defining how PersistentVolumes should be created when a PersistentVolumeClaim requests storage.

---

# Task 1 – Demonstrate Data Loss with emptyDir

## Objective

Understand why Pod storage is not permanent.

### Steps Performed

* Created a Pod using an **emptyDir** volume.
* Wrote a timestamp into `/data/message.txt`.
* Verified the file using:

```bash
kubectl exec <pod-name> -- cat /data/message.txt
```

* Deleted the Pod.
* Recreated the Pod.
* Checked the file again.

### Observation

The original file was lost because **emptyDir exists only while the Pod is running**.

The recreated Pod generated a **new timestamp**, proving the previous data was deleted.

### Verification

**Question**

Is the timestamp the same or different?

**Answer**

The timestamp is **different**, confirming that data stored in an **emptyDir** volume is deleted when the Pod is removed.

---

# Task 2 – Create a PersistentVolume (Static Provisioning)

## Objective

Create storage manually.

### PV Configuration

* Capacity: **1Gi**
* Access Mode: **ReadWriteOnce**
* Reclaim Policy: **Retain**
* Storage Type: **hostPath**
* Path:

```text
/tmp/k8s-pv-data
```

### Apply

```bash
kubectl apply -f pv.yaml
```

### Verify

```bash
kubectl get pv
```

Example

```text
NAME    CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS
my-pv   1Gi        RWO            Retain           Available
```

### Access Modes

| Access Mode         | Meaning                          |
| ------------------- | -------------------------------- |
| ReadWriteOnce (RWO) | Read and write by one node       |
| ReadOnlyMany (ROX)  | Read-only by multiple nodes      |
| ReadWriteMany (RWX) | Read and write by multiple nodes |

### Note

`hostPath` is suitable for **learning** but should **not be used in production** because the data is stored on a single node.

### Verification

**Question**

What is the status of the PV?

**Answer**

`Available`

---

# Task 3 – Create a PersistentVolumeClaim

## Objective

Request storage from Kubernetes.

### PVC Configuration

* Storage: **500Mi**
* Access Mode: **ReadWriteOnce**

### Apply

```bash
kubectl apply -f pvc.yaml
```

### Verify

```bash
kubectl get pvc
kubectl get pv
```

Output

```text
PVC Status : Bound
PV Status  : Bound
```

Kubernetes matched the PVC with the available PV based on:

* Capacity
* Access Mode

### Verification

**Question**

What does the **VOLUME** column show?

**Answer**

```text
my-pv
```

This indicates the PVC successfully bound to the manually created PV.

---

# Task 4 – Use the PVC in a Pod

## Objective

Verify that data survives Pod deletion.

### Steps

* Mounted the PVC at `/data`.
* Wrote data into:

```text
/data/message.txt
```

* Deleted the Pod.
* Recreated the Pod.
* Read the file again.

### Observation

The file still contained the previous data because it was stored inside the Persistent Volume.

### Verification

**Question**

Does the file contain data from both Pods?

**Answer**

**Yes.**

The Persistent Volume preserved the data across Pod recreation.

---

# Task 5 – StorageClasses and Dynamic Provisioning

## Objective

Understand how Kubernetes creates storage automatically.

### Commands

```bash
kubectl get storageclass

kubectl describe storageclass standard
```

### Cluster Information

| Property             | Value                 |
| -------------------- | --------------------- |
| Default StorageClass | standard              |
| Provisioner          | rancher.io/local-path |
| Reclaim Policy       | Delete                |
| Volume Binding Mode  | WaitForFirstConsumer  |

### Meaning of Important Fields

### Provisioner

Creates PersistentVolumes automatically.

Example

```text
rancher.io/local-path
```

---

### Reclaim Policy

Determines what happens after the PVC is deleted.

* Delete → Remove PV automatically
* Retain → Keep the PV

---

### Volume Binding Mode

Your cluster uses:

```text
WaitForFirstConsumer
```

Meaning Kubernetes waits until a Pod actually uses the PVC before creating and binding the PV.

### Dynamic Provisioning Flow

```text
Developer creates PVC
          │
          ▼
StorageClass receives request
          │
          ▼
Provisioner creates PV automatically
          │
          ▼
PVC binds to the new PV
```

### Verification

**Question**

What is the default StorageClass?

**Answer**

```text
standard
```

---

# Task 6 – Dynamic Provisioning

## Objective

Allow Kubernetes to create a PV automatically.

### Steps

Created a PVC with:

```yaml
storageClassName: standard
```

Initially the PVC remained **Pending** because the StorageClass used:

```text
VolumeBindingMode: WaitForFirstConsumer
```

After creating a Pod that used the PVC:

* Kubernetes automatically created a new PV.
* The PVC changed from **Pending** to **Bound**.

### Verify

```bash
kubectl get pv
```

Output

```text
NAME                                       STATUS
my-pv                                      Bound
pvc-54261eb6-668b-4803-9901-d75c9737f705   Bound
```

### Verification

**Question**

How many PVs exist?

**Answer**

**2**

### Which PV was manually created?

```text
my-pv
```

### Which PV was dynamically created?

```text
pvc-54261eb6-668b-4803-9901-d75c9737f705
```

The dynamic PV was automatically created by Kubernetes using the **standard StorageClass**.

---

# Static vs Dynamic Provisioning

| Feature                | Static Provisioning         | Dynamic Provisioning    |
| ---------------------- | --------------------------- | ----------------------- |
| PV Creation            | Manual                      | Automatic               |
| Administrator Required | Yes                         | No                      |
| Uses StorageClass      | No                          | Yes                     |
| Scalability            | Limited                     | Highly Scalable         |
| Recommended            | Small/Learning Environments | Production Environments |

---

# Commands Used

```bash
kubectl get pv

kubectl get pvc

kubectl describe pvc dynamic-pvc

kubectl get storageclass

kubectl describe storageclass standard

kubectl apply -f pv.yaml

kubectl apply -f pvc.yaml

kubectl apply -f dynamic-pvc.yaml

kubectl apply -f dynamic-pod.yaml

kubectl exec dynamic-pod -- cat /data/message.txt
```

---

# Key Takeaways

* Pods are ephemeral, but Persistent Volumes keep data safe.
* A PV is cluster storage, while a PVC is a request for storage.
* Kubernetes binds a PVC to a matching PV.
* Static provisioning requires an administrator to create PVs manually.
* Dynamic provisioning automatically creates PVs using a StorageClass.
* Your cluster's default StorageClass is **standard**.
* The provisioner is **rancher.io/local-path**.
* The reclaim policy is **Delete**.
* The volume binding mode is **WaitForFirstConsumer**.
* After completing the tasks, the cluster contained **two Persistent Volumes**:

  * **my-pv** (Manual / Static Provisioning)
  * **pvc-54261eb6-668b-4803-9901-d75c9737f705** (Automatic / Dynamic Provisioning)

