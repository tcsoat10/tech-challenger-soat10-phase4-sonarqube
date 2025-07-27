variable "sonarqube_admin_password" {
  description = "Senha do usuário admin do SonarQube"
  type        = string
  sensitive   = true
}
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    sonarqube = {
      source  = "rubenespadas/sonarqube"
      version = ">= 0.8.0"
    }
  }
}

provider "kubernetes" {
  # Configure para apontar para o cluster EKS existente
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

provider "sonarqube" {
  url   = var.sonarqube_url
  token = var.sonarqube_token
  # A senha do admin é usada apenas na configuração do Helm
}

variable "kubeconfig_path" {
  description = "Caminho para o kubeconfig do EKS"
  type        = string
}

variable "sonarqube_url" {
  description = "URL do SonarQube"
  type        = string
}

variable "sonarqube_token" {
  description = "Token de admin do SonarQube"
  type        = string
  sensitive   = true
}
