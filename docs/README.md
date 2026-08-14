## **Kubernetes Networking & Storage Demo**

A small multi-service app built purely as a learning exercise — the goal isn't the app's functionality, but demonstrating how containers in separate pods communicate, 
how Ingress routes and balances traffic, and how a persistent volume keeps data alive across pod restarts.

### **What it does**
Python app + HTML page — the main service. Lets you submit a name, list all saved names, and reset the list, backed by Redis (Submit, Show All Names, Reset Data buttons). A PersistentVolume is attached to this deployment, so data survives pod restarts.
Redis — separate pod/service used purely as the data store for the Python app.
NGINX — a standalone pod/service serving a static "Hello from NGINX service" page, used to demonstrate host-based routing alongside the main app.

Each part (Python+HTML, Redis, NGINX) has its own Deployment and Service. An Ingress sits in front of everything and routes traffic by hostname:

Host	Routes to
names-app	Python app (UI + Redis-backed logic)
nginx	NGINX static page

### **Stack**
Kubernetes (tested on minikube)
Python (app logic + HTML UI)
Redis (data store)
NGINX (static demo page)
Ingress (nginx controller) — host-based routing
PersistentVolumeClaim — persistent storage for the Python app

**Running locally (minikube)**
bash
**start the cluster**
minikube start

**enable the Ingress addon**
minikube addons enable ingress

**apply all manifests**
kubectl apply -f k8s/

**check everything is up**
kubectl get pods
kubectl get svc
kubectl get ingress

**expose the Ingress controller**
minikube tunnel

**Add both hosts to your hosts file (/etc/hosts on Linux/Mac, C:\Windows\System32\drivers\etc\hosts on Windows):**

127.0.0.1   names-app
127.0.0.1   nginx

Open in the browser:

http://names-app — the app (submit / show / reset names)
http://nginx — the NGINX demo page


### **Next steps**
Terraform configuration to deploy this to AWS (EKS) — see aws/ branch or folder
CI/CD pipeline for automated deployment
