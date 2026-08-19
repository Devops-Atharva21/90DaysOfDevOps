# Day 66 — Provision an EKS Cluster with Terraform Modules

## Overview

Today I provisioned an AWS EKS cluster using Terraform Registry modules instead of creating the infrastructure manually.

The main goal was to practice a real DevOps workflow:

**Terraform → VPC → EKS → kubectl → Nginx → Cleanup**

The infrastructure was designed to be repeatable and easy to destroy after the exercise.

---

# Task 1: Project Setup

## What I did

I created a new Terraform project directory:

```text
terraform-eks/
├── providers.tf
├── vpc.tf
├── eks.tf
├── variables.tf
├── outputs.tf
└── terraform.tfvars
```

### `providers.tf`

I configured the required Terraform providers:

- AWS provider
- Kubernetes provider

I pinned the AWS provider to:

```text
~> 5.0
```

I also configured the AWS region.

### `variables.tf`

I created variables to make the infrastructure configurable:

| Variable | Purpose | Default |
|---|---|---|
| `region` | AWS region | Set in tfvars |
| `cluster_name` | EKS cluster name | `terraweek-eks` |
| `cluster_version` | Kubernetes version | `1.31` |
| `node_instance_type` | Worker node instance type | `t3.medium` |
| `node_desired_count` | Desired worker nodes | `2` |
| `vpc_cidr` | VPC CIDR range | `10.0.0.0/16` |

### Commands used

```bash
terraform init
terraform fmt
terraform validate
```

### What I learned

Terraform providers define which cloud/platform APIs Terraform can work with, while variables make the configuration reusable and flexible.

---

# Task 2: Create the VPC with Registry Module

## What I did

Instead of manually creating every VPC resource, I used the Terraform Registry VPC module:

```text
terraform-aws-modules/vpc/aws
```

The VPC was configured with:

- CIDR: `10.0.0.0/16`
- 2 Availability Zones
- 2 public subnets
- 2 private subnets
- 1 NAT Gateway
- DNS hostnames enabled

The private subnets were used for EKS worker nodes.

### Network structure

```text
VPC: 10.0.0.0/16
│
├── AZ 1
│   ├── Public Subnet
│   └── Private Subnet
│
└── AZ 2
    ├── Public Subnet
    └── Private Subnet
```

### NAT Gateway

I used:

```hcl
enable_nat_gateway = true
single_nat_gateway = true
```

A single NAT Gateway was used to reduce the cost of the learning environment.

### EKS subnet tags

Public subnets:

```hcl
public_subnet_tags = {
  "kubernetes.io/role/elb" = 1
}
```

Private subnets:

```hcl
private_subnet_tags = {
  "kubernetes.io/role/internal-elb" = 1
}
```

### Why does EKS need public and private subnets?

Public subnets can be used for internet-facing AWS load balancers.

Private subnets are suitable for worker nodes because the nodes don't need to be directly exposed to the internet. They can use the NAT Gateway for outbound internet access.

### What do the subnet tags do?

The tags help AWS/Kubernetes identify which subnets can be used for external and internal load balancers.

### Commands used

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

### What I learned

Terraform Registry modules reduce repetitive configuration and make infrastructure easier to maintain.

---

# Task 3: Create the EKS Cluster with Registry Module

## What I did

I used the Terraform Registry EKS module:

```text
terraform-aws-modules/eks/aws
```

The EKS cluster was connected to the VPC created in Task 2.

Important configuration:

```hcl
vpc_id     = module.vpc.vpc_id
subnet_ids = module.vpc.private_subnets
```

This means the EKS module uses the VPC module's outputs instead of hardcoded IDs.

### EKS configuration

- Cluster name: `terraweek-eks`
- Kubernetes version: `1.31`
- Public API endpoint access enabled
- Managed node group enabled
- Desired nodes: 2
- Minimum nodes: 1
- Maximum nodes: 3
- Instance type: `t3.medium`

### Node group

The managed node group was:

```text
terraweek_nodes
```

The worker nodes were placed in the private subnets.

### Commands used

```bash
terraform init
terraform fmt
terraform validate
terraform plan
```

### What I learned

Terraform modules can be connected together using outputs and inputs.

For example:

```text
VPC Module
   │
   ├── vpc_id
   └── private_subnets
          │
          ▼
      EKS Module
```

This is an important pattern for reusable Terraform infrastructure.

---

# Task 4: Apply and Connect kubectl

## What I did

I applied the Terraform configuration to create the EKS infrastructure:

```bash
terraform apply
```

EKS creation took several minutes because AWS needs to create the control plane, IAM resources, networking, and worker nodes.

I also configured Terraform outputs for:

- Cluster name
- Cluster endpoint
- Cluster region

### Connect kubectl

I updated my kubeconfig using:

```bash
aws eks update-kubeconfig --name terraweek-eks --region us-west-2
```

Then I verified the cluster:

```bash
kubectl get nodes
kubectl get pods -A
kubectl cluster-info
```

## Authentication issue I encountered

Initially, `kubectl` was connected to a local Kind cluster instead of EKS.

I identified this by checking:

```bash
kubectl config current-context
```

The Kind cluster had a node named:

```text
my-cluster-control-plane
```

I then updated the kubeconfig to use the EKS cluster.

I also verified AWS authentication with:

```bash
aws sts get-caller-identity
```

and checked the EKS cluster status:

```bash
aws eks describe-cluster   --name terraweek-eks   --region us-west-2   --query 'cluster.status'
```

The cluster status was:

```text
ACTIVE
```

I generated an EKS authentication token with:

```bash
aws eks get-token   --cluster-name terraweek-eks   --region us-west-2
```

After fixing the EKS access/authentication issue, `kubectl` successfully connected to the EKS cluster.

### What I learned

`kubectl` uses the kubeconfig context to decide which Kubernetes cluster it communicates with.

AWS CLI credentials and Kubernetes/EKS access must both be working for `kubectl` to access an EKS cluster.

---

# Task 5: Deploy a Workload on the Cluster

## What I did

I created a Kubernetes directory:

```text
k8s/
└── nginx-deployment.yaml
```

The YAML contained:

- Nginx Deployment
- 3 Nginx replicas
- Nginx container using `nginx:latest`
- LoadBalancer Service

### Deployment

The deployment used:

```text
replicas: 3
```

This created three Nginx pods.

### Service

The service was configured as:

```text
type: LoadBalancer
```

This allows AWS to provision an external load balancer for the application.

### Deploy the workload

I used:

```bash
kubectl apply -f k8s/nginx-deployment.yaml
```

Then checked the resources:

```bash
kubectl get nodes
kubectl get deployments
kubectl get pods
kubectl get svc
```

I also used:

```bash
kubectl get svc nginx-service
```

to check the LoadBalancer status.

## Issue I encountered

At first, I checked the Nginx Service while `kubectl` was connected to a Kind cluster.

The service showed:

```text
EXTERNAL-IP   <pending>
```

The reason was that Kind does not automatically provision an AWS Load Balancer.

I then switched `kubectl` to the EKS context and verified the EKS cluster connection.

### What I learned

A Kubernetes `LoadBalancer` Service behaves differently depending on the Kubernetes environment.

In EKS, AWS integration can provision AWS load-balancing resources, while a local Kind cluster does not automatically create an AWS Load Balancer.

---

# Task 6: Destroy Everything

## What I did

After completing the exercise, the infrastructure should be cleaned up to avoid unnecessary AWS charges.

First, Kubernetes resources should be deleted:

```bash
kubectl delete -f k8s/nginx-deployment.yaml
```

This allows the AWS Load Balancer associated with the Kubernetes Service to be removed.

Then Terraform resources can be destroyed:

```bash
terraform destroy
```

### Resources to verify after cleanup

AWS should have no leftover:

- EKS clusters
- EKS worker node instances
- TerraWeek VPC
- NAT Gateway
- Elastic IPs
- Load Balancers
- Related networking resources

### What I learned

`terraform destroy` is an important part of the Terraform workflow.

Terraform makes infrastructure:

```text
Create → Manage → Destroy
```

This is especially important when practicing with AWS resources that can generate charges.

---

# Final Architecture

```text
                    AWS
                     │
                  VPC
             10.0.0.0/16
                     │
          ┌──────────┴──────────┐
          │                     │
    Public Subnets        Private Subnets
          │                     │
          │                EKS Nodes
          │                 ┌───┴───┐
          │                 │       │
          │               Node 1  Node 2
          │                 │       │
          └──────────┐      └───┬───┘
                     │          │
               Load Balancer   Nginx
                                │
                           3 Replicas
```

# Important Commands Cheat Sheet

## Terraform

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
```

## AWS

```bash
aws sts get-caller-identity

aws eks update-kubeconfig   --name terraweek-eks   --region us-west-2

aws eks describe-cluster   --name terraweek-eks   --region us-west-2   --query 'cluster.status'
```

## Kubernetes

```bash
kubectl config current-context
kubectl get nodes
kubectl get pods -A
kubectl get deployments
kubectl get pods
kubectl get svc
kubectl cluster-info
kubectl apply -f k8s/nginx-deployment.yaml
kubectl delete -f k8s/nginx-deployment.yaml
```

# Key Takeaways

1. Terraform Registry modules simplify infrastructure creation.
2. VPC modules can create complete AWS networking with reusable configuration.
3. EKS can use private subnets for worker nodes.
4. Public and private subnet tags help Kubernetes/AWS identify load-balancer subnets.
5. EKS managed node groups simplify worker-node management.
6. Terraform module outputs can be used as inputs to other modules.
7. `aws eks update-kubeconfig` connects `kubectl` to an EKS cluster.
8. Always check the current Kubernetes context before running `kubectl` commands.
9. A `LoadBalancer` Service behaves differently on Kind and EKS.
10. Always destroy AWS practice infrastructure after completing the exercise to avoid unnecessary costs.

# Day 66 Summary

Today I learned how to provision an AWS EKS environment using Terraform modules instead of manually creating every AWS resource.

The complete workflow was:

```text
Terraform
   ↓
VPC Module
   ↓
EKS Module
   ↓
Managed Node Group
   ↓
kubectl
   ↓
Nginx Deployment
   ↓
LoadBalancer
   ↓
Terraform Destroy
```

This exercise demonstrated how Terraform and Kubernetes can work together to create a repeatable DevOps infrastructure workflow.

