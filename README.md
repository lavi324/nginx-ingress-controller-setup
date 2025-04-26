Open a new GitHub repo, pull the repo into the cloud shell and config the GitHub user for a future Push requests.
Enable "Kubernetes Engine API" (for GCP).
Create the "production" namespace that gonna be used (the rest of the namespaces will be created in the future Terraform script).
Add the Helm repo's that gonna be used in the future Terraform script and make sure these are the latest chart versions.
Set up a git ignore file that will prevent a high memory Terraform files to be pushed. 
Plan and Apply Terraform script.
Access Your API Key in https://site.financialmodelingprep.com/developer/docs/dashboard
Create two directories called "backend" and "frontend".
Install Express (backend web application framework for building RESTful APIs with Node.js) in the backend directory and ensure that all the default folder Structure were created.
Install axios (HTTP Client for node.js and the browser), cors (security mechanism implemented by web browsers to prevent unauthorized access to resources on a web page from different origins) and mongoose (Object Data Modeling library for MongoDB).
Set up the backend file and the Docker file.
Install React (JavaScript library for building user interfaces) in the frontendend directory and ensure that all the default folder Structure were created.
Install axios again.
Set up the frontend file and the Docker file.
Create 3 Docker hub repositories (frontend (test), backend and frontend Helm chart).
Build and Push the Docker images.
Create Kubernetes files with the new Docker images and apply.
Search for the pods services external IP's and see that the MERN codes are working (the frontend web page, the backand REST API and the Mogno DB collection.
Now you can see that the app codes are working properly and can start to add more automation infrastructures.
Create a Helm directory with the Chart.yaml and the frontend app kubernetes file.
Add the Jenkinsfile (CI pipeline).
Add a directory with the Jenkins pod agent's docker file (to ensure that in the pipeline each agent pod starts with all tools already installed).
Add a scripts directory and insert the increment tags script.
Change the Jenkins app Kubernetes service type to LB (to get an external IP for the Jenkins UI service) and access.
In the login page insert the user "admin" and search for the admin password with the command:                                                                                 kubectl get secret jenkins -n jenkins   -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode; echo
Download Kubernetes, Docker, Node and git plug-in's and configure the GitHub and DockerHub credentials.
Create a pipeline and configure the project's GitHub URL.
Make sure that the pipeline is working well with no errors in the console output.
Change the ArgoCD app Kubernetes service type to NodePort (You can not use more then 4 LB's in the GCP free plan) and access to the UI.
Create a firewall to allow external HTTP traffic to ArgoCD NodePort service.                                                                         
In the login page insert the user "admin" and search for the admin password with the command:                                                                                 kubectl get secret argocd-initial-admin-secret -n argo -o jsonpath="{.data.password}" | base64 --decode && echo
Add the DockerHub repo in settings and enable OCI (standard for a containers management).
