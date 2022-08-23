output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = aws_elasticsearch_domain.this.endpoint
}

output "kibana_endpoint" {
  description = "Domain-specific endpoint for kibana without https scheme"
  value       = aws_elasticsearch_domain.this.kibana_endpoint
}

output "domain_id" {
  description = "Unique identifier for the domain"
  value       = aws_elasticsearch_domain.this.domain_id
}

output "domain_name" {
  description = "Name of the Elasticsearch domain"
  value       = aws_elasticsearch_domain.this.domain_name
}

output "admin_user" {
  description = "OpenSearch admin user"
  value       = var.admin_user
}

output "admin_pass" {
  description = "OpenSearch admin user pass"
  value       = var.admin_pass
}
