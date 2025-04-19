provider "google" {
  project = "coherent-answer-457220-s3"
  region  = "us-central1"
}

# Define the VPC network
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

# Define the subnet within the VPC with a valid private IP range
resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.vpc_network.self_link
  region        = "us-central1"
}

# Define the Kubernetes cluster (GKE)
resource "google_container_cluster" "my_cluster" {
  name     = "my-cluster"
  location = "us-central1"

  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  node_pool {
    name               = "default"
    initial_node_count = 2
    node_locations     = ["us-central1-a"]

    node_config {
      machine_type = "e2-medium"
      disk_size_gb = 50
    }
  }
}

# Helm provider configuration
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Jenkins Helm chart
resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = "jenkins"
  version          = "5.8.36"
  timeout          = 800
  create_namespace = true
}

# Argo CD Helm chart
resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argo"
  version          = "7.8.26"
  timeout          = 800
  create_namespace = true
}

# MongoDB Helm chart
resource "helm_release" "mongodb" {
  name             = "mongodb"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "mongodb"
  namespace        = "mongo"
  version          = "16.5.1"
  timeout          = 800
  create_namespace = true
}
