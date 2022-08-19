locals {
  app_prefix  = "clamour"
  aws_profile = "clamour"
  aws_region  = "ap-northeast-1"
}

terraform {
  required_version = "~> 1.2.0"

  backend "s3" {
    bucket  = "clamour"
    key     = "eks/terraform.tfstate"
    profile = "${local.aws_profile}"
    region  = "${local.aws_region}"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.12.0"
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "${local.app_prefix}-vpc"
  cidr   = "10.0.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # enable AWS Load Balancer Controller subnet-discovery
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  # enable AWS Load Balancer Controller subnet-discovery
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}
