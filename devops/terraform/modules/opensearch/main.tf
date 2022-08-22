locals {
  roles = merge({
    for filename in var.role_files :
    replace(basename(filename), "/\\.(ya?ml|json)$/", "") =>
    length(regexall("\\.ya?ml$", filename)) > 0 ? yamldecode(file(filename)) : jsondecode(file(filename))
  }, {})
  role_mappings = merge({
    for filename in var.role_mapping_files :
    replace(basename(filename), "/\\.(ya?ml|json)$/", "") =>
    length(regexall("\\.ya?ml$", filename)) > 0 ? yamldecode(file(filename)) : jsondecode(file(filename))
  }, {})
}

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
      master_user_password = "Clamour-Pass-1234"
    }
  }
#  advanced_security_options {
#    enabled                        = true
#    internal_user_database_enabled = false
#    master_user_options {
#      master_user_arn = "${data.aws_caller_identity.current.arn}"
#    }
#  }
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

resource "elasticsearch_opensearch_roles_mapping" "master" {
  for_each = {
    for key in ["all_access", "security_manager"] :
    key => try(local.role_mappings[key], {})
  }

  role_name     = each.key
  description   = try(each.value.description, "")
  backend_roles = concat(try(each.value.backend_roles, []), [var.master_user])
  hosts         = try(each.value.hosts, [])
  users         = try(each.value.users, [])
}

resource "elasticsearch_opensearch_role" "this" {
  for_each = local.roles

  role_name           = each.key
  description         = try(each.value.description, "")
  cluster_permissions = try(each.value.cluster_permissions, [])

  dynamic "index_permissions" {
    for_each = try([each.value.index_permissions], [])

    content {
      index_patterns          = try(index_permissions.value.index_patterns, [])
      allowed_actions         = try(index_permissions.value.allowed_actions, [])
      document_level_security = try(index_permissions.value.document_level_security, "")
    }
  }

  dynamic "tenant_permissions" {
    for_each = try([each.value.tenant_permissions], [])

    content {
      tenant_patterns = try(tenant_permissions.value.tenant_patterns, [])
      allowed_actions = try(tenant_permissions.value.allowed_actions, [])
    }
  }

  depends_on = [elasticsearch_opensearch_roles_mapping.master]
}

resource "elasticsearch_opensearch_roles_mapping" "this" {
  for_each = {
    for key, value in local.role_mappings :
    key => value if !contains(["all_access", "security_manager"], key)
  }

  role_name     = each.key
  description   = try(each.value.description, "")
  backend_roles = try(each.value.backend_roles, [])
  hosts         = try(each.value.hosts, [])
  users         = try(each.value.users, [])

  depends_on = [elasticsearch_opensearch_role.this]
}

resource "elasticsearch_index" "this" {
  name               = "${var.index_name}"
  number_of_shards   = 1
  number_of_replicas = 1
  mappings           = <<EOF
{
  "people": {
    "_all": {
      "enabled": false
    },
    "properties": {
      "email": {
        "type": "text"
      }
    }
  }
}
EOF
  depends_on = [elasticsearch_opensearch_roles_mapping.this]
}
