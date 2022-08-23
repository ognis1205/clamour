provider "elasticsearch" {
  #aws_profile       = "${var.aws_profile}"
  #aws_region        = "${var.aws_region}"
  url               = "https://${aws_elasticsearch_domain.this.endpoint}"
  username          = "${var.admin_user}"
  password          = "${var.admin_pass}"
  sign_aws_requests = false 
  # SEE: https://github.com/phillbaker/terraform-provider-elasticsearch/issues/124
  healthcheck       = false
  # SEE: https://github.com/olivere/elastic/issues/312
  sniff             = false
}
