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
  host                   = "https://77E908145F4D1F4A69FB8AFCC3959989.gr7.us-east-1.eks.amazonaws.com"
  cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJSStEWDVOQUF2b2t3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBM01qY3lNelUxTVRSYUZ3MHpOVEEzTWpZd01EQXdNVFJhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUMzY3BrZkt0Mk53SHJnOW1oU3NXTjA0eXBCdkZXL1RjblM0aGlrajNuZ3BJdGhuTTlWakFOU2FXVkMKdm5sanpXemF6MWxDV1k0YmhtVUw2bDJPM1BrdGZnenZSVm41YWdiNnR6blZkRjFRcGw0azRjU3o3RDcxbTVwbApDS09oUy81NTNKcStrNEFYUHhyUGhaeDUrZlhyaXhuNmRzWVJxcUxIbzVpelJnU0FlWkxtNE5tdktIN08zQzBGCnRtdTE5OCt4aU5JYmNIN3IvMXB0dEtLSzdKYURCMzNjdlUwMzZENjNzOU45NjdkakUxeDBiK29vUnVhQ3pUSW0KU29uS2Iwc2MycnZUVGYwTmVsQ0N6MU5SYjRrY0w5N1hyM0srdWJFbVVSL2NvMFV1RTJCbXlZdCtXYVpoQ2NxYQoxUWtsV0I3SVEzMTJ4S01FUVByTWJtcFkzRElEQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJRYWZzM0FlT0ZXbjAxOW44K3JNazNkUlc3ZUNqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQlhmazFXQ21iTApKc051Q1FXZnJjM3QwK3JXNWlsYzQveUE1a1BPbTVTOXh5K0wwaHRwbVdqQzhzZTNiRzZQZHhaK1A2cENQbnZoCmluTk1wZVo4Y2drZHBmRnBzNGRGVFM3LzNRRU5TTkpIQ0tBejJKb3N0VzRwU2pUSVNmWEhvNm5QVzRZZ3lCOTkKZTlGYmhheXQwMU5DQWwyTkx5NHZlUFhERTNuUnJJcGwyaUJKRnlGWm9OYXpqV0d5SStZMkEyVE8wbUM3YVIvNQpaaGczVDA4K0J3Wk9jQzgzcit5ZEZCTHF6VE1xZ3hQQ2NoNW1hQ2FLeVEvN3FFQVBUQm1xZlNSQU53ME8xWEd3ClVLOXlaWkp4UHcvRlVRQm1TZGNWZ0NlUlZ0c3k2SnhyTFNnbTdQd2REUnVTT1dsa1pBM1ZMMjkrbk1oa0hOTlAKQjhkbDdCcnRuQTRDCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
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