resource "sonarqube_project" "payment" {
  key         = "payment-microservice"
  name        = "payment-microservice"
  visibility  = "public"
}

resource "sonarqube_project" "auth" {
  key         = "auth-microservice"
  name        = "auth-microservice"
  visibility  = "public"
}

resource "sonarqube_project" "stock" {
  key         = "stock-microservice"
  name        = "stock-microservice"
  visibility  = "public"
}

resource "sonarqube_project" "order" {
  key         = "order-microservice"
  name        = "order-microservice"
  visibility  = "public"
}
