# create the artifact registry
resource "google_artifact_registry_repository" "ar_repo" {
  repository_id = "wfa-ctgz-rclsfr-dev"
  project       = local.application_project_id
  location      = "us-east4"
  mode          = "STANDARD_REPOSITORY"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis["artifactregistry.googleapis.com"]]
}

# iam permissions for artifact registry
resource "google_project_iam_binding" "ar_repo_iam" {
  project = local.application_project_id
  role    = "roles/artifactregistry.admin"
  members = [
    "serviceAccount:project-service-account@${local.application_project_id}.iam.gserviceaccount.com",
    "serviceAccount:service-${local.application_project_id}@serverless-robot-prod.iam.gserviceaccount.com",
    "serviceAccount:${google_service_account.gh_sa.email}"
  ]
  depends_on = [google_artifact_registry_repository.ar_repo]
}