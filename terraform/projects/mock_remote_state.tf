locals {
  use_mock = (terraform.workspace == "default" || terraform.workspace == "test")
}

data "terraform_remote_state" "sonarqube" {
  backend = local.use_mock ? "local" : "s3"
  config = local.use_mock ? {
    path = "${path.module}/../mock/mock_sonarqube_outputs.tfstate"
    } : {
    bucket = "soattc-sonarqube"
    key    = "env:/${terraform.workspace}/sonarqube/terraform.tfstate"
    region = "us-east-1"
  }
}