terraform {
  required_providers {
    elasticsearch = {
      source  = "phillbaker/elasticsearch"
      version = "2.0.4"
    }
    http = {
      source  = "hashicorp/http"
      version = "1.1"
    }
  }
}
