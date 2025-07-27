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

variable "sonarqube_admin_password" {
  description = "Senha do usuário admin do SonarQube"
  type        = string
  sensitive   = true
}
