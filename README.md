*Short explanations about the project*:

This project delivers a fully automated, production-ready MERN stack (MongoDB, Express.js, React, Node.js) on Google Cloud by using Terraform for infrastructure provisioning, Docker and Helm to package and deploy containers as Kubernetes Deployments and Services, Jenkins for continuous integration and ArgoCD for GitOps-driven continuous delivery.

The React frontend page pulls the latest Apple index price from an external indexes API and displays it along with your public IP and access timestamp via an Express REST API, while a backend job periodically fetches fresh index data and stores each quote plus the viewer’s IP and timestamp in a MongoDB collection.

*Start*:

Open a new GitHub repo, pull the repo into the cloud shell and config the GitHub user for a future Push requests.

Enable "Kubernetes Engine API" (for GCP).

Create the "production" namespace that gonna be used (the rest of the namespaces will be created in the future Terraform script).

Add the Helm repos that going to be used in the future Terraform script and make sure these are the latest chart versions.

Set up a git ignore file that will prevent a high memory Terraform files to be pushed. 

Plan and Apply Terraform script.

Get your API Key from https://site.financialmodelingprep.com/developer/docs/dashboard

Create two directories called "backend" and "frontend".

Install Express (backend web application framework for building RESTful APIs with Node.js) in the backend directory and ensure that all the default folder structure were created.

Install axios (HTTP Client for node.js and the browser), cors (security mechanism implemented by web browsers to prevent unauthorized access to resources on a web page from different origins) and mongoose (Object Data Modeling library for MongoDB).

Set up the backend file and the Docker file.

Install React (JavaScript library for building user interfaces) in the frontend directory and ensure that all the default folder structure were created.

Install axios again.

Set up the frontend file and the Docker file.

Create 3 Docker hub repositories (frontend (test), backend and frontend Helm chart).

Build and Push the Docker images.

Create Kubernetes files with the new Docker images and apply.

Search for the pods services external IP's and see that the MERN codes are working (the frontend web page, the b3ckand REST API and the Mongo DB collection.

Now you can see that the app codes are working properly and can start to add more automations infrastructure.

Create a Helm directory with the Chart.yaml and the frontend app kubernetes file.

Add the Jenkinsfile (CI pipeline).

Add a directory with the Jenkins pod agent's docker file (to ensure that in the pipeline each agent pod starts with all tools already installed).

Add a scripts directory and insert the increment tags script.

Change the Jenkins app Kubernetes service type to LB (to get an external IP for the Jenkins UI service) and access.

In the login page insert the user "admin" and search for the admin password with the command:                                                                          kubectl get secret jenkins -n jenkins   -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode; echo

Download Kubernetes, Docker, Node and git plugins and configure the GitHub and DockerHub credentials.

Create a pipeline and configure the project's GitHub URL.

Make sure that the pipeline is working well with no errors in the console output.

Change the ArgoCD app Kubernetes service type to NodePort (You can not use more than 4 LB's in the GCP free plan) and access to the UI.

Create an ingress firewall to allow your device public IP to transmit HTTP traffic to ArgoCD NodePort service (because GKE automatically creates a firewall rule (when you are using a LB) that allows traffic from anywhere in the Internet, but if you are using NodePort (expose to the internet some port from the Node external IP) GKE is not creating a firewall automatically. 

In the login page insert the user "admin" and search for the admin password with the command:                                                                          kubectl get secret argocd-initial-admin-secret -n argo -o jsonpath="{.data.password}" | base64 --decode && echo

Add the DockerHub repo in settings and enable OCI (standard for container management).

Create a new Argo app with the Helm chart DockerHub repo and use "*" as the chart tag (for the latest tag).

Access to the new service that Argo created and see that the frontend page is working well.

Follow those to change something in the frontend web page: change the frontend/src/App.jsx file -> push the new change to the GitHub repo -> execute the Jenkins pipeline and after approximately 3 minutes the frontend web page will sync with the new change. (dont forget to "git pull" to the terminal repo after every pipeline execution because there is a files changes).                                                                                                                                   ***as you see those steps could be handled with a simple automation so follow those steps:***                                                                                                                                             
Generate a Jenkins API token for the the future script with those steps: Get into the Jenkins UI -> click on the downward arrow next to your username in the top right corner -> Security -> Add new token .                                                                                                                                                     
Create an env variables file that you will use in the future script because you going to push him into GitHub and you don't want that hackers will see any sensitive data (use the "export" Bash command in the file).                                                                                                                                                                                        
Create a script with the new Jenkins API token and the new env variables that will automate the steps in row 77.  
