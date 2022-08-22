variable "aws_profile" {
  description = "AWS profile"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "master_user" {
  description = "The ARN for the master user of the cluster"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Application name prefix"
  type        = string
}

variable "index_name" {
  description = "Application index name"
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
  default     = 50
}

variable "role_files" {
  description = "A set of all role files to create."
  type        = set(string)
  default     = []
}

variable "role_mapping_files" {
  description = "A set of all role mapping files to create."
  type        = set(string)
  default     = []
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
