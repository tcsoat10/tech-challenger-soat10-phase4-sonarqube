output "sonar_token" {
  description = "Sonar User Token"
  value       = var.sonar_token
}

output "sonar_url" {
  description = "Sonarqube URL"
  value       = data.terraform_remote_state.sonarqube.outputs.sonarqube_lb_endpoint
}