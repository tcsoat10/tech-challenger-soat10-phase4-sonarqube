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
  host                   = "https://E525C3DB9B07E8AEE3E8D975B5AC2007.gr7.us-east-1.eks.amazonaws.com"
  cluster_ca_certificate = base64decode("LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJZEJzWTBVdEswK2t3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TlRBM01qZ3hOVEkwTWpWYUZ3MHpOVEEzTWpZeE5USTVNalZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUN5bzVON29sVDNLK0ROS0twaHRsWjc3OVkwdXNBM3RXR05zU3g2TGgyeldJU0NTV2xVcEx0OU1IdlkKYVdwNzdJWFRUOXJ1Z2lTWHhidjIzeHdBNjhlalZFc0tONDFTdDN5R2ozZ3lOYXgybFJKWk4rNUpVOGNXbXJyWgpPNDFFNVBBK21hNjgyN0RVSEVLQkVXZVZtOXpEZXpmcTczMlMyaTlFYVd5M00yK3FNV2NEK1JFZDBOSmR0NjBQCjMzd0R0QVI2M2hnT2xqc2dtaXhRYjV5RGx2VFNKYjg3ZE1zN09XUkVOek9OamVGVEtlVVhESVYvcTBGTnJVbFEKM0tDS1IwMHFnWjJKUGVSSEtWS1JZbEl5TnJOYTFaZ0hlY0plc1hUWVZ2bnVsakxRa3J3WnhTV1VkYXNobzFpbwpzdFRpclhvYkpWV1ovVkJhQ3puTjdRRGVvTS92QWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJUSXJlMlFEb1dyL3NNdW03eUlsZFhiV0t4UmJUQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQVBRM0g1Sm9MdgpBTjdjeGp2ZUx4emxmMlcxem9EYzRHMGxRc0R0RTdwQmF3aUhRSzY4cVYyYkI2WldRTS8yQjFOSnBJcGJiZEhaCjMrTEFzNDQ3Wk1IaVgyVjh2K3ZOQ0t6aVJHQjdLQ0RMd2xIcGxSM25QdVN6NW1NOXBEQ2NjZUowTEh5N3BySkgKcC92V0x5Umw0cGpGcUJFOTFqalR1UmxZa21BejBHYllFMUhsQXJFMngvUHNYd3B4d0hpL1U1RUMwQWV3bHJybwoxMWtVVlF5KytCMlllZ2pGNTExYXVDOG1Cb3M2OWxpWVM1N25Cb1dIUmhxSWZ3ZG1naXN6bUdUKzJ3Tk8xcEd0CklPcmVtbjVrL2l2NzRwdDMwa0tGOEQ5TEdaa2MyUzlRSVRDODQ1Z2JHd0svSURBdWRYRWJGN2JlczBmVlJ4VUQKdDNnMUdMampGZ1lBCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K")
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