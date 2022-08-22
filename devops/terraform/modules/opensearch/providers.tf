provider "elasticsearch" {
  #aws_profile       = "${var.aws_profile}"
  #aws_region        = "${var.aws_region}"
  url               = aws_elasticsearch_domain.this.endpoint
  #  sign_aws_requests = true
  # SEE: https://github.com/phillbaker/terraform-provider-elasticsearch/issues/124
  #healthcheck       = false
  #insecure          = true
}
