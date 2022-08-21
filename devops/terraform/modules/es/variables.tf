variable "domain_name" {
  description = "Application name prefix"
  type        = string
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp2"
}

variable "volume_size" {
  description = "EBS volume size"
  type        = number
  default     = 500
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
