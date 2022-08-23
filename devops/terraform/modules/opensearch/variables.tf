#variable "aws_profile" {
#  description = "AWS profile"
#  type        = string
#}

#variable "aws_region" {
#  description = "AWS region"
#  type        = string
#}

variable "opensearch_version" {
  description = "The version of OpenSearch to deploy"
  type        = string
  default     = "1.0"
}

variable "master_user_arn" {
  description = "The ARN for the master user of the cluster"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Application name prefix"
  type        = string
}

variable "admin_user" {
  description = "OpenSearch admin user"
  type        = string
  default     = "admin"
}

variable "admin_pass" {
  description = "OpenSearch admin user pass"
  type        = string
  default     = "Clamour-Pass-1234"
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

variable "index_template_files" {
  description = "A set of all index template files to create"
  type        = set(string)
  default     = []
}

variable "index_files" {
  description = "A set of all index files to create"
  type        = set(string)
  default     = []
}

variable "role_files" {
  description = "A set of all role files to create"
  type        = set(string)
  default     = []
}

variable "role_mapping_files" {
  description = "A set of all role mapping files to create."
  type        = set(string)
  default     = []
}

variable "ism_policy_files" {
  description = "A set of all ISM policy files to create"
  type        = set(string)
  default     = []
}

#variable "whitelisted_ips" {
#  type        = list(string)
#  description = "Whitelisted IPs to access ES"
#  default     = []
#}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "access_policy" {
  statement {
    actions   = ["es:*"]
    resources = ["arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
#    condition {
#      test     = "IpAddress"
#      variable = "aws:SourceIp"
#      values   = var.whitelisted_ips
#    }
  }
}
