output "sonarqube_lb_endpoint" {
  description = "Endpoint do Load Balancer do sonarqube"
  value       = kubernetes_service.sonarqube_lb.status[0].load_balancer[0].ingress[0].hostname
}