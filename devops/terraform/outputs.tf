output "aws_auth_config_map" {
  description = "AWS Auth ConfigMap in YAML format"
  value = module.eks.aws_auth_configmap_yaml
}

output "opensearch_endpoint" {
  description = "Elasticsearch endpoint used to submit index, search, and data upload requests"
  value = module.opensearch.endpoint
}

output "es_index_name" {
  description = "The name of the Elasticsearch index"
  value = module.opensearch.index_name
}
