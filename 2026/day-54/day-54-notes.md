
# Day 54 -- Kubernetes ConfigMaps and Secrets

## Introduction

Applications need configuration such as database URLs, ports, feature
flags, API endpoints, and credentials. Hardcoding these values inside a
container image is not a good practice because every configuration
change requires rebuilding and redeploying the image.

Kubernetes solves this problem using: - **ConfigMaps** -- Store
non-sensitive configuration data. - **Secrets** -- Store sensitive
information such as passwords, API keys, and tokens.

## ConfigMap

A **ConfigMap** stores non-sensitive configuration as key-value pairs
and can be consumed by Pods as environment variables or mounted files.

## Secret

A **Secret** stores sensitive data such as passwords, API keys, and
certificates. Secret values are Base64 encoded by default.

## Task 1 -- Create a ConfigMap from Literals

Create `app-config` using:

``` bash
kubectl create configmap app-config \
  --from-literal=APP_ENV=production \
  --from-literal=APP_DEBUG=false \
  --from-literal=APP_PORT=8080
```

Inspect:

``` bash
kubectl describe configmap app-config
kubectl get configmap app-config -o yaml
```

**Explanation:** `--from-literal` creates key-value pairs directly from
the command line. ConfigMap values are stored as plain text.

## Task 2 -- Create a ConfigMap from a File

Create `default.conf`:

``` nginx
server {
    listen 80;
    location / { return 200 "Welcome to Nginx\n"; }
    location /health { return 200 "healthy\n"; }
}
```

Create ConfigMap:

``` bash
kubectl create configmap nginx-config --from-file=default.conf=default.conf
```

**Explanation:** The key `default.conf` becomes the filename when
mounted.

## Task 3 -- Use ConfigMaps in a Pod

-   Use `envFrom` + `configMapRef` to inject environment variables.
-   Mount `nginx-config` at `/etc/nginx/conf.d`.
-   Verify:

``` bash
kubectl exec <pod> -- curl -s http://localhost/health
```

Expected:

    healthy

## Task 4 -- Create a Secret

``` bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD=s3cureP@ssw0rd
```

Inspect:

``` bash
kubectl get secret db-credentials -o yaml
```

Decode:

``` bash
echo '<base64-value>' | base64 --decode
```

**Explanation:** Base64 is encoding, not encryption.

## Task 5 -- Use Secrets in a Pod

-   Inject `DB_USER` using `secretKeyRef`.
-   Mount Secret at `/etc/db-credentials` with `readOnly: true`.
-   Each Secret key becomes a file and mounted values are plaintext.

## Task 6 -- Update a ConfigMap

Create:

``` bash
kubectl create configmap live-config --from-literal=message=hello
```

Patch:

``` bash
kubectl patch configmap live-config --type merge -p '{"data":{"message":"world"}}'
```

Mounted ConfigMap files update automatically after \~30--60 seconds.
Environment variables do not.

## Key Takeaways

-   ConfigMaps store non-sensitive configuration.
-   Secrets store sensitive data.
-   ConfigMaps are plain text; Secrets are Base64 encoded.
-   Both can be used as environment variables or mounted files.
-   Volume-mounted ConfigMaps update automatically; environment
    variables require Pod restart.

