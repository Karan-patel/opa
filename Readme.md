# OPA Deployment Guide

### Prerequisites

Before starting, ensure you have the following:

##### Minikube: Make sure Minikube is installed and running on your local machine with container(e.g. docker).

##### kubectl: Ensure you have kubectl installed and configured to interact with your Minikube cluster.

##### Policy File: Prepare the policy file policy.rego that defines your OPA policy.

This guide will walk you through deploying Open Policy Agent (OPA) on Kubernetes using Minikube.
We'll load a policy file into a ConfigMap and then will apply configurations and deployments to run the OPA container.
Please follow below steps !

#### Step 1: Create a Kubernetes Namespace for OPA
It is not mandatory however good practice to have separate namespaces with having few advantages in container management.
   ```sh
   kubectl create namespace opa
   ```

#### Step 2: Create a Kubernetes ConfigMap to hold the policy file. We'll directly load the policy file into the ConfigMap.

This ConfigMap containing the policy is volume mounted into the container. This will allow OPA to load the policy from
the file system.

   ```sh
   kubectl create configmap opa-policy --from-file=config/opa/policy.rego -n opa
   ```

#### Step 3: Apply configurations and deployment to run container.

'opa-service.yaml' contains K8-service configurations to expose application running in pod to network.
'opa-deployment.yaml' contains standard K8-deployment configurations.

Apply the configurations to Minikube cluster and start deployment:

```sh
kubectl apply -f config/opa/opa-service.yaml -n opa
kubectl apply -f config/opa/opa-deployment.yaml -n opa
```

#### Step 4: Verify that OPA is running and the policy is loaded correctly by checking the status of the OPA deployment:
Verify that pods created and OPA is accessible.
```sh
   kubectl get pods -n opa
```
Verify that OPA service is accessible over http via below curl command.

```sh
curl --location 'http://localhost:8181/v1/data/mycoolservice/authz' \
--header 'Content-Type: application/json' \
--data '{
    "input": {
        "method": "POST",
        "user": {
            "role": "admin",
            "authenticated":true
        }
    }
}'
```