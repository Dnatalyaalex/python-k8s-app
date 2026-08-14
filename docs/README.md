## **Kubernetes Networking & Storage Demo**

A small multi-service app built purely as a learning exercise — the goal isn't the app's functionality, but demonstrating how containers in separate pods communicate, 
how Ingress routes and balances traffic, and how a persistent volume keeps data alive across pod restarts.

### **What it does**

Python app + HTML page — the main service. Lets you submit a name, list all saved names, and reset the list, backed by Redis (Submit, Show All Names, Reset Data buttons). A PersistentVolume is attached to this deployment, so data survives pod restarts.
Redis — separate pod/service used purely as the data store for the Python app.
NGINX — a standalone pod/service serving a static "Hello from NGINX service" page, used to demonstrate host-based routing alongside the main app.

Each part (Python+HTML, Redis, NGINX) has its own Deployment and Service. An Ingress sits in front of everything and routes traffic by hostname:

Host	Routes to <br>
names-app	Python app (UI + Redis-backed logic) <br>
nginx	NGINX static page <br>

### **Stack** <br>
Kubernetes (tested on minikube) <br>
Python (app logic + HTML UI) <br>
Redis (data store) <br>
NGINX (static demo page) <br>
Ingress (nginx controller) — host-based routing <br>
PersistentVolumeClaim — persistent storage for the Python app <br>

**Running locally (minikube)** <br>
bash <br>
**start the cluster** <br>
`minikube start` <br>

**enable the Ingress addon** <br>
`minikube addons enable ingress`

**apply all manifests** <br>
`kubectl apply -f k8s/`

**check everything is up** <br>
`kubectl get pods` <br>
`kubectl get svc` <br>
`kubectl get ingress` <br>

**expose the Ingress controller** <br>

`minikube tunnel`

**Add both hosts to your hosts file (/etc/hosts on Linux/Mac, C:\Windows\System32\drivers\etc\hosts on Windows):**

`127.0.0.1   names-app` <br>
`127.0.0.1   nginx` <br>

Open in the browser:

http://names-app — the app (submit / show / reset names) <br>
http://nginx — the NGINX demo page 
 

### **Next steps** <br>
Terraform configuration to deploy this to AWS (EKS) — see aws/ branch or folder <br>
CI/CD pipeline for automated deployment
