data "terraform_remote_state" "project_ids" {
  backend = "gcs"

  config = {
    prefix = "gcp-ttec-projects"
    bucket = "ttec-iac-terraform-state"
  }
}

## Internal Ip for equipment-returns dev 

data "google_compute_address" "internal-lb-ip" {
  name    = "internal-lb-ip"
  region = "us-east4"
  project = local.application_project_id
}


data "google_secret_manager_secret_version" "return_ssl_crt" {
  provider = google
  project = local.application_project_id
  secret = "return_ssl_crt"
  version = "latest"
  
}

data "google_secret_manager_secret_version" "return_ssl_key"{
  provider = google
  project = local.application_project_id
  secret = "return_ssl_key"
  version = "latest"
}