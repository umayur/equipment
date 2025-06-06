# list of APIs to be enable
resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "certificatemanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "iap.googleapis.com",
    "deploymentmanager.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "pubsub.googleapis.com",
    "run.googleapis.com",
    "storage.googleapis.com",
    "containerregistry.googleapis.com",
    "storage-api.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudidentity.googleapis.com",
    "vpcaccess.googleapis.com"
  ])
  service = each.key
  project = local.application_project_id
}