**What is an Ingress Controller?**
An Ingress Controller is a Kubernetes component that manages external HTTP and HTTPS traffic entering the cluster. 
It acts as a smart router, directing requests to internal services based on path or host. 
Ingress Controllers also allow centralized TLS management and help reduce cloud costs by exposing multiple services through a single LoadBalancer and external IP.

**Why am i want to use NGINX as the Ingress controller in my project?**
I want use NGINX because it's a stable, widely adopted Ingress controller that fits perfectly for small to medium-sized projects like mine.
It allows me to manage routing, TLS certificates, and load balancing with a simple and clear configuration. 

**What do I currently have in the project before adding an Ingress controller?**
I am running five core services:
A **frontend** React application served via Nginx and exposed to the internet through a Kubernetes LoadBalancer service.
A **backend** Express server exposed via a LoadBalancer that fetches Apple index data, store client data in MongoDB, and serves the data to the frontend via a REST API.
A **MongoDB** database used to store client public IP and client access timestep, accessible internally within the cluster via a ClusterIP service.
A **Jenkins** server used for CI pipeline automation, deployed with a LoadBalancer to allow external access to the Jenkins UI.
An **Argo CD** controller used to manage CD, exposed via a NodePort and accessible through the external IP of the cluster node only for my public IP.
This setup uses multiple external IPs and load balancers, which increases both operational cost and deployment mess. 
Moving forward, I plan to implement access through a single NGINX Ingress controller to simplify API requeses routing, improve security, and reduce cost.

***The main focus of this project is the k8s/ingress directory files, which contains the Ingress configuration for managing HTTP routing within the Kubernetes cluster.                                                    This project is a continuation of the https://github.com/lavi324/mern-gke-cicd-pipeline project.***

**NGINX Ingress Controller setup:**

install the NGINX Helm chart in the new NGINX NS.

Run a Helm upgrade command on the Jenkins and Argo Helm charts to configure the Jenkin and ArgoCD UI's to be served under the /jenkins and /argo path's.

Create an Ingress resource in the production namespace that exposes:

**/ → frontend (production)**

**/api/sp500 → backend (production)**

**/jenkins → Jenkins (in jenkins namespace)**

**/argo → ArgoCD (in argo namespace)**

But the problem now is that the Kubernetes Ingress resources can only reference Services in the **same namespace** and we have two services that in another namespace (ArgoCD and Jenkins).

The solution is to create an **ExternalName Service** that implement a DNS redirector service in your namespace that simply redirects to a real service in another namespace.

**Now, if a pod, service, or process running inside the production namespace makes a network request to a service name like jenkins or argo-cd-argocd-server, Kubernetes will resolve that name using the ExternalName service and automatically redirect the request to the real service in its original namespace.**

________________________________________________________________________________________________________________

Q: How can both Argo CD and the React frontend apps be served through the same LoadBalancer IP on port 80?

A: NGINX Ingress listens on port 80 and acts as a reverse proxy that routes incoming HTTP requests based on their URL paths. Each path is mapped to a different Kubernetes Service.                                        This allows multiple applications to be exposed through a single LoadBalancer IP and port, with no port conflicts.
















