resource "aws_elasticsearch_domain" "this" {
  domain_name           = "${var.domain_name}"
  elasticsearch_version = "OpenSearch_1.1"

  ebs_options {
    ebs_enabled = true
    volume_type = "${var.volume_type}"
    volume_size = var.volume_size
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = "clamour-pass"
    }
  }
}

resource "aws_elasticsearch_domain_policy" "this" {
  domain_name     = aws_elasticsearch_domain.this.domain_name
  access_policies = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          AWS = "*"
        },
	Action = "es:ESHttp*"
	Resource = "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${aws_elasticsearch_domain.this.domain_name}/*"
      }
    ]
  })
}
