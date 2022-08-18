terraform {
  required_version = "~> 1.0.0"
  backend "s3" {
    bucket  = "clamour"
    key     = "eks/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "clamour"
  }
}