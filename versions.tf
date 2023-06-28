terraform {
  required_version = ">= 1.3"

  required_providers {
    jq = {
      source  = "massdriver-cloud/jq"
      version = "0.2.1"
    }
  }
}
