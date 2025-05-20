**What is an Ingress Controller?**
An Ingress Controller is a Kubernetes component that manages external HTTP and HTTPS traffic entering the cluster. 
It acts as a smart router, directing requests to internal services based on path or host. 
Ingress Controllers also allow centralized TLS management and help reduce cloud costs by exposing multiple services through a single LoadBalancer and external IP.

**Why am i want to use NGINX as the Ingress controller in my project?**
I want use NGINX because it's a stable, widely adopted Ingress controller that fits perfectly for small to medium-sized projects like mine.
It allows me to manage routing, TLS certificates, and load balancing with a simple and clear configuration. 

**What do I currently have in the project before adding an Ingress controller?**
In my current main project, *https://github.com/lavi324/mern-gke-cicd-pipeline*, i am running five core services:
A **frontend** React application served via Nginx and exposed to the internet through a Kubernetes LoadBalancer service.
A **backend** Express server exposed via a LoadBalancer that fetches Apple index data, store client data in MongoDB, and serves the data to the frontend via a REST API.
A **MongoDB** database used to store client public IP and client access timestep, accessible internally within the cluster via a ClusterIP service.
A **Jenkins** server used for CI pipeline automation, deployed with a LoadBalancer to allow external access to the Jenkins UI.
An **Argo CD** controller used to manage CD, exposed via a NodePort and accessible through the external IP of the cluster node only for my public IP.
This setup uses multiple external IPs and load balancers, which increases both operational cost and deployment mess. 
Moving forward, I plan to implement access through a single NGINX Ingress controller to simplify API requeses routing, improve security, and reduce cost.

**NGINX Ingress Controller setup:**

Create a new NS for the NGINX Helm chart.

install the NGINX 
Helm chart in the new NS.

Run a Helm upgrade command on the Jenkins Helm chart to configure the Jenkins UI to be served under the /jenkins path (helm upgrade jenkins jenkins/jenkins --namespace jenkins --reuse-values --set controller.jenkinsUriPrefix="/jenkins") .















