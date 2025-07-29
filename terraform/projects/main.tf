terraform {
  backend "s3" {
    bucket = "soattc-sonarqube-projects"
    key    = "sonarqube-projects/terraform.tfstate"
    region = "us-east-1"
  }
}

terraform {
  required_providers {
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "~> 0.16"
    }
  }
}


provider "sonarqube" {
  host  = "http://${data.terraform_remote_state.sonarqube.outputs.sonarqube_lb_endpoint}"
  token = var.sonar_token
}

resource "sonarqube_project" "auth-app" {
  project    = "soattc-auth-app"
  name       = "Auth App"
  visibility = "private"
}

resource "sonarqube_project" "order-app" {
  project    = "soattc-order-app"
  name       = "Order App"
  visibility = "private"
}

resource "sonarqube_project" "payment-app" {
  project    = "soattc-payment-app"
  name       = "Payment App"
  visibility = "private"
}

resource "sonarqube_project" "stock-app" {
  project    = "soattc-stock-app"
  name       = "Stock App"
  visibility = "private"
}