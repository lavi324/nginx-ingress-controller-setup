Open a new GitHub repo, pull the repo into the cloud shell and config the GitHub user for a future Push requests.
Enable "Kubernetes Engine API" (for GCP).
Create the "production" namespace that gonna be used (the rest namespaces will be created in the future Terraform script).
Add the Helm repo's that gonna be used in the future Terraform script and make sure these are the latest chart versions.
Set up a git ignore file that will prevent a high memory Terraform files to be pushed. 
Plan and Apply Terraform script.
