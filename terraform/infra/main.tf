provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "soattc-sonarqube"
    key    = "sonarqube/terraform.tfstate"
    region = "us-east-1" # ajuste para sua região
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

resource "kubernetes_deployment" "sonarqube" {
  metadata {
    name      = "sonarqube"
    namespace = "default"
    labels = {
      app = "sonarqube"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "sonarqube"
      }
    }
    template {
      metadata {
        labels = {
          app = "sonarqube"
        }
      }
      spec {
        container {
          name  = "sonarqube"
          image = "086134737169.dkr.ecr.us-east-1.amazonaws.com/sonarqube:latest"
        }
      }
    }
  }
}

resource "kubernetes_service" "sonarqube_lb" {
  depends_on = [kubernetes_deployment.sonarqube]
  metadata {
    name      = "sonarqube-lb"
    namespace = "default"
  }
  spec {
    selector = {
      app = "sonarqube"
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 8000
    }
  }
}