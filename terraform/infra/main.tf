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

provider "kubernetes" {
  host                   = "https://C15332589EE67C6A069E0A9A4F83BDD8.yl4.us-east-1.eks.amazonaws.com"
  cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJYXlSYklCbngvZWd3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBM01qa3dNekl4TWpkYUZ3MHpOVEEzTWpjd016STJNamRhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUR5d3E1OUhlWmhvOHdrRG52TXRXSFdPMTR5eFlSd1I4QU14ODdjSU1ESHVFeHBpOVZPTjhWNm93QmUKeTErWWkvVVhkVFo1U1B1NTVDVTl2SmxWUmJQcitubUtqUUVxUDQ5UnJhSU4yNVNmOFd2Z2VkbUZuNVdSZ2Ezawo2RWFZbUx5bVZoTnQ0NURCUWlMTXc5Qnp6ZnFYK0hSWUpFV3J1UWlIOTE5THh2SlVlQk9jTjF0aENFZzIzNEFGCmttNDlWQXkzRGJ0UUowZDRXNVJMQWlqVFRBc3F5cnVDR3ozL1paM3hhOXR0RUd3MkFTbmlMZStMV2V4bXNDS2IKY1ZyUVord2RHUWlJNlc5ajlzNk1NU3pyZUJUQ21QeXR4cHZta3c5YndQZFgwWEFWQnVIc3FESWExelFjY2pwVQpoaHRBUVZNTzhxZTFhMW56VlZ1aEtNbEI0bGVuQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJSa053Q0t3UXZ6ZEU4ZzMxU3lBcWdmMVVQRDd6QVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ3ZZZXJXYlMzVgpDZE9HenVhWlJMZU9pZkJXWVlXWmtoZjRoKzkrUUZQNkpFL2wrVE1NR1hkd2NiUTJsMnNiVVcwTGppZHpmejVNCmJ0c0xUOSs3VWk4UUR6YmEwTmFqR2RHZWVPbUxJWnM1c1hBd0dQNDNrdytGcWFaMUYwc2JiV2o1V040RkVkVTcKMHF5U0F1UnNjeWNXMlVjU3dRdzlMS2Z5N2pOUnZzS0I0eUtvMm82WHExS2I3RVgyZk1pbU9CbnFnWGN4aFJIeAoxTi83MktlZzFpQ0tXdTFCeVRhWGFJWUNXR0pRS3cxZUJMTzRiblFhbXRzclRDT2pCZEJLVDZVenU4RU9QQWZ3Ck9KV0h6bGRzYzFpdityaG5kYWRleGdIalVFZ1R4WDdsQzRJVC9DSkR4UmhSTzFVeVo2NjM0NW1xMGZ2NTRxbGkKNEl5WHgzS01hMk9mCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
  token                  = data.aws_eks_cluster_auth.cluster.token
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
          port {
            container_port = 9000
          }
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
      port        = 9001
      target_port = 9000
    }
  }
}