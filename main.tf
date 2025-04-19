provider "google" {
  project = "coherent-answer-457220-s3"
  region  = "us-central1"
  zone    = "us-central1-a"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
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
  name               = "my-cluster"
  location           = "us-central1"
  network            = google_compute_network.vpc_network.id
  subnetwork         = google_compute_subnetwork.subnet.id
  deletion_protection = false

  node_pool {
    name              = "default"
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
  namespace        = "mongo"
  create_namespace = true
  wait             = true
  timeout          = 800

  depends_on = [google_container_cluster.my_cluster]
}
