# **OPA Deployment Guide**

### Prerequisites

Before starting, ensure you have the following:

 **Minikube**: Make sure Minikube is installed and running on your local machine with container(e.g. docker).

 **kubectl**: Ensure you have kubectl installed and configured to interact with your Minikube cluster.

 **Policy File in rego**: Prepare the policy file policy.rego that defines your OPA policy.

**This guide gives you walk through for deploying Open Policy Agent (OPA) on Minikube.**

First We'll load a policy file into a ConfigMap and mount it to container volume. Then simply we will simply create container and expose over cluster through network.
All these resources we will wrap into namespace 'opa' ! 

Please follow below steps !

#### Step 1: Create a Kubernetes Namespace for OPA
**It is not mandatory however good practice to have separate namespaces with having few advantages in container management.**
   ```sh
   kubectl create namespace opa
   ```

#### Step 2: Create a Kubernetes ConfigMap to hold the policy file. We'll directly load the policy file into the ConfigMap.

**This ConfigMap containing the policy is volume mounted into the container. This will allow OPA to load the policy from
the file system.**

   ```sh
   kubectl create configmap opa-policy --from-file=config/opa/policy.rego -n opa
   ```

#### Step 3: Deploy our container and service !

**'opa-service.yaml' contains K8-service configurations to expose application running in pod to network.
'opa-deployment.yaml' contains standard K8-deployment configurations.**

Apply the configurations to Minikube cluster and start deployment:

```sh
kubectl apply -f config/opa/opa-service.yaml -n opa
kubectl apply -f config/opa/opa-deployment.yaml -n opa
```

#### Step 4: Verify that OPA is running and the policy is loaded correctly by checking the status of the OPA deployment:
**Verify that pods created and OPA is accessible.**
```sh
kubectl get pods -n opa
```

#### Step 5 : To connect with application running in container exposed as service from local sometimes need SSH-tunneling.
```bash
kubectl port-forward svc/opa 8181:8181 -n opa
```

**Verify that OPA service is accessible over http and our policy is loaded properly !**

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