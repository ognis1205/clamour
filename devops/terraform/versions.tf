terraform {
  required_version = "1.2.0"

#  backend "s3" {
#    bucket  = "clamour"
#    key     = "eks/terraform.tfstate"
#    profile = "clamour"
#    region  = "ap-northeast-1"
#  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.27.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.12.1"
    }
  }
}
