terraform {
  backend "gcs" {
    prefix = "gcp-equipment-return-dev"
    bucket = "ttec-iac-terraform-state"
  }
}