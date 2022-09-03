locals {
  index_templates = merge({
    for filename in var.index_template_files :
    replace(basename(filename), "/\\.(ya?ml|json)$/", "") =>
    length(regexall("\\.ya?ml$", filename)) > 0 ? yamldecode(file(filename)) : jsondecode(file(filename))
  }, {})

  indices = merge({
    for filename in var.index_files :
    replace(basename(filename), "/\\.(ya?ml|json)$/", "") =>
    length(regexall("\\.ya?ml$", filename)) > 0 ? yamldecode(file(filename)) : jsondecode(file(filename))
  }, {})

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

  ism_policies = merge({
    for filename in var.ism_policy_files :
    replace(basename(filename), "/\\.(ya?ml|json)$/", "") =>
    length(regexall("\\.ya?ml$", filename)) > 0 ? yamldecode(file(filename)) : jsondecode(file(filename))
  }, {})

  current_ip   = chomp(data.http.ip.body)

  allowed_cidr = (var.allowed_cidr == null) ? "${local.current_ip}/32" : var.allowed_cidr
}

resource "aws_elasticsearch_domain" "this" {
  domain_name           = "${var.domain_name}"
  elasticsearch_version = "OpenSearch_${var.opensearch_version}"
  access_policies       = data.aws_iam_policy_document.access_policy.json

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
      master_user_name     = "${var.admin_user}"
      master_user_password = "${var.admin_pass}"
    }
  }
}

resource "aws_elasticsearch_domain_saml_options" "this" {
  domain_name = aws_elasticsearch_domain.this.domain_name

  saml_options {
    enabled                 = true
    subject_key             = var.saml_subject_key
    roles_key               = var.saml_roles_key
    session_timeout_minutes = var.saml_session_timeout
    master_user_name        = var.saml_master_user_name
    master_backend_role     = var.saml_master_backend_role

    idp {
      entity_id        = var.saml_entity_id
      metadata_content = sensitive(replace(var.saml_metadata_content, "\ufeff", ""))
    }
  }
}

# *** COMMENT OUT PURPOSEFULLY ***
# NOTICE: This resouce tries to PUT policy JSON to '_opendistro/_security/api/rolesmapping/<role>' which
#         is supposed to be '_plugins/_security/api/rolesmapping/<role>'.

#resource "elasticsearch_opensearch_roles_mapping" "master_user" {
#  for_each = {
#    for key in ["all_access", "security_manager"] :
#    key => try(local.role_mappings[key], {})
#  }
#
#  role_name     = each.key
#  description   = try(each.value.description, "")
#  backend_roles = concat(try(each.value.backend_roles, []), [data.aws_caller_identity.current.arn])
#  hosts         = try(each.value.hosts, [])
#  users         = try(each.value.users, [])
#}

#resource "elasticsearch_opensearch_roles_mapping" "this" {
#  for_each = {
#    for key, value in local.role_mappings :
#    key => value if !contains(["all_access", "security_manager"], key)
#  }
#
#  role_name     = each.key
#  description   = try(each.value.description, "")
#  backend_roles = try(each.value.backend_roles, [])
#  hosts         = try(each.value.hosts, [])
#  users         = try(each.value.users, [])
#
#  depends_on = [elasticsearch_opensearch_role.this]
#}

# *** COMMENT OUT PURPOSEFULLY ***
# NOTICE: This resouce tries to PUT policy JSON to '_opendistro/_security/api/roles/<role>' which
#         is supposed to be '_plugins/_security/api/roles/<role>'.

#resource "elasticsearch_opensearch_role" "this" {
#  for_each = local.roles
#
#  role_name           = each.key
#  description         = try(each.value.description, "")
#  cluster_permissions = try(each.value.cluster_permissions, [])
#
#  dynamic "index_permissions" {
#    for_each = try([each.value.index_permissions], [])
#
#    content {
#      index_patterns          = try(index_permissions.value.index_patterns, [])
#      allowed_actions         = try(index_permissions.value.allowed_actions, [])
#      document_level_security = try(index_permissions.value.document_level_security, "")
#    }
#  }
#
#  dynamic "tenant_permissions" {
#    for_each = try([each.value.tenant_permissions], [])
#
#    content {
#      tenant_patterns = try(tenant_permissions.value.tenant_patterns, [])
#      allowed_actions = try(tenant_permissions.value.allowed_actions, [])
#    }
#  }
#
#  depends_on = [elasticsearch_opensearch_roles_mapping.master_user]
#}

# *** COMMENT OUT PURPOSEFULLY ***
# NOTICE: This resouce tries to PUT policy JSON to '_opendistro/_ism/policies<policy>' which
#         is supposed to be '_plugins/_ism/policies/<policy>'.

resource "elasticsearch_opensearch_ism_policy" "this" {
  for_each = local.ism_policies

  policy_id = each.key
  body      = jsonencode({ "policy" = each.value })

#  depends_on = [elasticsearch_opensearch_roles_mapping.master_user]
}

resource "elasticsearch_index_template" "this" {
  for_each = local.index_templates

  name = each.key
  body = jsonencode(each.value)

#  depends_on = [elasticsearch_opensearch_roles_mapping.master_user]
}

resource "elasticsearch_index" "this" {
  for_each = local.indices

  name               = each.key
  number_of_shards   = try(each.value.number_of_shards, "")
  number_of_replicas = try(each.value.number_of_replicas, "")
  refresh_interval   = try(each.value.refresh_interval, "")
  analysis_filter    = jsonencode(try(each.value.analysis.filter, {}))
  analysis_analyzer  = jsonencode(try(each.value.analysis.analyzer, {}))
  mappings           = jsonencode(try(each.value.mappings, {}))
  aliases            = jsonencode(try(each.value.aliases, {}))
  force_destroy      = true

  depends_on = [elasticsearch_index_template.this]

  lifecycle {
    ignore_changes = [
      number_of_shards,
      number_of_replicas,
      refresh_interval,
    ]
  }
}
