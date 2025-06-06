locals {
  application_project_id     = data.terraform_remote_state.project_ids.outputs.projects.equipment-return-dev.project_id
  application_project_number = data.terraform_remote_state.project_ids.outputs.projects.equipment-return-dev.project_number
  nonprod_vpc_id            = "vpc-engage-nonprod"
  nonprod_vpc_host          = "network-hosts-8342"
  region                     = "us-east4"
} 

# list of service accounts to assign the serverless vpc access permission 
locals {
  serviceAccounts = [
    "serviceAccount:service-${local.application_project_number}@gcp-sa-vpcaccess.iam.gserviceaccount.com",
    "serviceAccount:service-${local.application_project_number}@serverless-robot-prod.iam.gserviceaccount.com",
    "serviceAccount:${local.application_project_number}@cloudservices.gserviceaccount.com"
  ]
}


# list of roles to assign to github service_account
locals {
  roles = [
    "roles/iam.workloadIdentityUser",
    "roles/run.admin",
    "roles/run.serviceAgent",
    "roles/secretmanager.admin",
    "roles/secretmanager.secretAccessor"
  ]
}