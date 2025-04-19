provider "google" {
  project = "coherent-answer-457220-s3"
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Get GCP client auth token for Kubernetes provider
data "google_client_config" "default" {}

# Get info about the GKE cluster after creation
data "google_container_cluster" "my_cluster" {
  name     = google_container_cluster.my_cluster.name
  location = google_container_cluster.my_cluster.location
  depends_on = [google_container_cluster.my_cluster]
}

# Kubernetes provider using GKE dynamic config
provider "kubernetes" {
  host                   = data.google_container_cluster.my_cluster.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

# Helm provider using the same Kubernetes config
provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.my_cluster.endpoint
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

resource "google_container_cluster" "my_cluster" {
  name                = "my-cluster"
  location            = "us-central1"
  network             = google_compute_network.vpc_network.id
  subnetwork          = google_compute_subnetwork.subnet.id
  deletion_protection = false

  node_pool {
    name               = "default"
    initial_node_count = 1
    node_locations     = ["us-central1-a"]

    node_config {
      machine_type = "e2-medium"
      disk_size_gb = 40
    }
  }
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = "jenkins"
  create_namespace = true
  wait             = true
  timeout          = 800

  depends_on = [google_container_cluster.my_cluster]
}

resource "helm_release" "argo_cd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argo"
  create_namespace = true
  wait             = true
  timeout          = 800

  depends_on = [google_container_cluster.my_cluster]
}

resource "helm_release" "mongodb" {
  name             = "mongodb"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "mongodb"
  version          = "14.12.3"
  namespace        = "mongo"
  create_namespace = true
  wait             = true
  timeout          = 800

  depends_on = [google_container_cluster.my_cluster]
}
