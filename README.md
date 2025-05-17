**What is an Ingress Controller?**
An Ingress Controller is a Kubernetes component that manages external HTTP and HTTPS traffic entering the cluster. 
It acts as a smart router, directing requests to internal services based on path or host. 
Ingress Controllers also allow centralized TLS management and help reduce cloud costs by exposing multiple services through a single LoadBalancer and external IP.

**Why am I using NGINX as the Ingress controller in my project?**
I'm using NGINX because it's a stable, widely adopted Ingress controller that fits perfectly for small to medium-sized projects like mine.
It allows me to manage routing, TLS certificates, and load balancing with a simple and clear configuration. 

_____________________________________________________________________________________________________________

In my main project, *mern-gke-cicd-pipeline*, I realized the need for an Ingress controller.
I chose to implement one because of **those reasons**:
It allows me to expose multiple services (like frontend and backend) using a single external IP, which reduces LB's cost and simplifies access to the web pages.
It makes it easy to enable HTTPS and manage TLS certificates.

**What do I currently have in the project before adding an Ingress controller?**







