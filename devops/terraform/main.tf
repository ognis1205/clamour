locals {
  prefix      = "clamour"
  aws_profile = "clamour"
  aws_region  = "ap-northeast-1"
#  ebs_block_device = {
#    block_device_name = "/dev/xvda",
#    volume_type = "gp2"
#    volume_size = "500"
#  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"
  name    = "${local.prefix}-vpc"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  cidr            = "10.0.0.0/16"
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

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.28.0"
  cluster_name    = "${local.prefix}-k8s"
  cluster_version = "1.23"

  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = false
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    clamour = {
      desired_size   = 2
      instance_types = ["t2.xlarge"]
    }
  }

  node_security_group_additional_rules = {
    admission_webhook = {
      description                   = "Admission Webhook"
      protocol                      = "tcp"
      from_port                     = 0
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }

    ingress_node_communications = {
      description = "Ingress Node to node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }

    egress_node_communications = {
      description = "Egress Node to node"
      protocol    = "tcp"
      from_port   = 0
      to_port     = 65535
      type        = "egress"
      self        = true
    }

    # cert-manager require ACME self check using http protocol
    egress_http_internet = {
      description = "Egress HTTP to internet"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # flux require ssh access to clone git repository
    egress_ssh_internet = {
      description = "Egress SSH to internet"
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      type        = "egress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "es" {
  source      = "./modules/es"
  domain_name = "${local.prefix}-es"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
