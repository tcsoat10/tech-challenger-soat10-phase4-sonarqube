resource "helm_release" "sonarqube" {
  name       = "sonarqube"
  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = "10.4.0+691"
  namespace  = "sonarqube"
  create_namespace = true

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "postgresql.enabled"
    value = "true"
  }
  set {
    name  = "postgresql.postgresqlPassword"
    value = "sonarpass"
  }
  set {
    name  = "sonarqube.adminPassword"
    value = var.sonarqube_admin_password
  }
}
