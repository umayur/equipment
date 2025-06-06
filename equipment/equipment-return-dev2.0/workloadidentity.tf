# github workload identity service account
resource "google_service_account" "gh_sa" {
  account_id   = "github-sa"
  display_name = "github-sa"
  project      = local.application_project_id
  description  = "Service Account for GitHub CICD"
}

# assign roles on service account to run the nessaccery actions 
resource "google_project_iam_member" "gh_sa_iam" {
  member     = "serviceAccount:${google_service_account.gh_sa.email}"
  project    = local.application_project_id
  role       = each.value
  for_each   = toset(local.roles)
  depends_on = [google_service_account.gh_sa]
}

# create workload identity pool for github
resource "google_iam_workload_identity_pool" "gh_wi_pool" {
  workload_identity_pool_id = "github"
  display_name              = "github"
  description               = "Workload Identity Pool for GitHub"
  project                   = local.application_project_id
}

# create the workload identity pool provider
resource "google_iam_workload_identity_pool_provider" "gh_wi_pool_prvdr" {
  display_name                       = "github"
  workload_identity_pool_id          = "github"
  workload_identity_pool_provider_id = "github"
  project                            = local.application_project_id
  attribute_condition                = "assertion.repository_owner == 'Engage-App-Delivery'"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  description = "Workload Identity Provider - GitHub"
  depends_on  = [google_iam_workload_identity_pool.gh_wi_pool]
}

# adding repository to the workload identity pool for authentication and access the repo 
resource "google_service_account_iam_binding" "gh_sa_iam_repo" {
  service_account_id = google_service_account.gh_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${local.application_project_id}/locations/global/workloadIdentityPools/github/attribute.repository/Engage-App-Delivery/equipment-return-dev2.0",
    "principalSet://iam.googleapis.com/projects/${local.application_project_id}/locations/global/workloadIdentityPools/github/attribute.repository/Engage-App-Delivery/"
  ]
  depends_on = [google_iam_workload_identity_pool_provider.gh_wi_pool_prvdr]
}