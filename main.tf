provider "google" {
  project = "coherent-answer-457220-s3"
  region  = "us-central1"  # Change this to your desired region
}

# Define the VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# Define the subnet within the VPC with the specified IP range
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "220.15.4.0/24"
  network       = google_compute_network.vpc_network.self_link
  region        = "us-central1"  # Change this to your desired region
}

# Define the Kubernetes cluster
resource "google_container_cluster" "my_cluster" {
  name     = "my-cluster"
  location = "us-central1"  # Change this to your desired region

  # Use the subnet created above
  network   = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link  # Use the subnet's self-link as subnetwork

  # Node pool configuration
  node_pool {
    name       = "default"
    initial_node_count = 2  # Specify the desired number of nodes

    node_locations = ["us-central1-a"]  # Specify the zone here

    node_config {
      machine_type = "e2-medium"  # Change this to your desired machine type
      disk_size_gb = 50           # Adjust the disk size as needed (default is 100GB)
    }

    # Autoscaling configuration (should match existing state)
    autoscaling {
      location_policy      = "BALANCED"
      max_node_count       = 2
      min_node_count       = 0
      total_max_node_count = 0
      total_min_node_count = 0
    }
  }
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"  # Path to your kubeconfig file
  }
}

# Install Helm charts
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "jenkins"  # This refers to the repository name you added with `helm repo add jenkins https://charts.jenkins.io`
  chart      = "jenkins/jenkins"
  namespace  = "jenkins"
  version    = "5.8.36"
  timeout = 800
  create_namespace = true
}

resource "helm_release" "argo-cd" {
  name       = "argo-cd"
  repository = "argo"  # This refers to the repository name you added with `helm repo add argo https://argoproj.github.io/argo-helm`
  chart      = "argo/argo-cd"
  namespace  = "argo"
  version    = "7.8.26"
  timeout = 800
  create_namespace = true
}

resource "helm_release" "mongodb" {
  name             = "mongodb"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "mongodb"
  namespace        = "mongo"
  version          = "16.5.1"
  timeout          = 800
  create_namespace = true
}
