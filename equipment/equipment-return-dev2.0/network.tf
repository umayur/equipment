resource "google_compute_subnetwork" "subnet-use4-equip-return-dev" {
  name          = "subnet-use4-equip-return-dev"
  ip_cidr_range = "10.177.148.144/28"
  region        = "us-east4"
  network       = local.nonprod_vpc_id
  project       = local.nonprod_vpc_host
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}


# Creating Serverless VPC Connector Connection in Project and Connection to Shared Host VPC Host Project
resource "google_vpc_access_connector" "equip-dev-srv-vpc" {
  name = "equip-dev-srv-vpc"
  project = local.application_project_id
  region = local.region
  machine_type = "e2-micro"
  min_instances = 5
  max_instances = 10
  subnet {
    name       = google_compute_subnetwork.subnet-use4-equip-return-dev.name
    project_id = local.nonprod_vpc_host
  }
}

# adding service account permissions in shared network host
resource "google_project_iam_member" "srvrlss_vpc" {
  project    = local.nonprod_vpc_host
  role       = "roles/compute.networkUser"
  for_each   = toset(local.serviceAccounts)
  member     = each.value
  depends_on = [google_project_service.apis["vpcaccess.googleapis.com"]]
}
