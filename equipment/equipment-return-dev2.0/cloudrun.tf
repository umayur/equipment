# Creating Network Endpoint Group for Cloud Run UI
resource "google_compute_region_network_endpoint_group" "equip-returns-dev-ui-reg-neg" {
  project = local.application_project_id
  region = local.region
  name = "equip-returns-dev-ui-neg"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.equip-returns-dev-ui-frontend.name
  }
}

resource "google_cloud_run_service" "equip-returns-dev-ui-frontend" {
  project  = local.application_project_id
  name     = "equip-returns-dev-ui-frontend"
  location = "us-east4"
  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
  template {
    spec {
      service_account_name = "project-service-account@${local.application_project_id}.iam.gserviceaccount.com"
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        ports {
          container_port = 5000
        }
        env {
          name  = "ASPNETCORE_ENVIRONMENT"
          value = "Development"
        }
        env {
          name  = "ASPNETCORE_URLS"
          value = "http://*:5000"
        }

      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-connector" =  google_vpc_access_connector.equip-dev-srv-vpc.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
    }
  }
  autogenerate_revision_name = true

  lifecycle {
    ignore_changes = [
      metadata,
      template
    ]
  }
}

resource "google_cloud_run_service_iam_member" "equip-dev-ui-authenticated" {
  project = local.application_project_id
  location = local.region
  service = google_cloud_run_service.equip-returns-dev-ui-frontend.name
  role = "roles/run.invoker"
  member = "domain:ttec.com"
}

resource "google_compute_region_backend_service" "ui_backend" {
  name                  = "ui-backend"
  project               = local.application_project_id
  region                = "us-east4"
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"
  timeout_sec           = null
  health_checks = null

  backend {
    group = google_compute_region_network_endpoint_group.equip-returns-dev-ui-reg-neg.id
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
}


###########################cloud Run for API####################################

# Creating Network Endpoint Group for Cloud Run API
resource "google_compute_region_network_endpoint_group" "equip-returns-dev-api-neg" {
  project = local.application_project_id
  region = local.region
  name = "equip-returns-dev-api-neg"
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.equip-dev-api.name
  }
}
resource "google_cloud_run_service" "equip-dev-api" {
  name     = "equip-dev-api"
  project  = local.application_project_id
  location = local.region
  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
  template {
    spec {
      service_account_name = "project-service-account@${local.application_project_id}.iam.gserviceaccount.com"
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        ports {
          container_port = 5000
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "10"
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.equip-dev-srv-vpc.name
      }
    }
  }
  autogenerate_revision_name = true
  lifecycle {
    ignore_changes = [
      metadata,
      template
    ]
  }
}

resource "google_project_iam_member" "run_invoker" {
  project = local.application_project_id
  role = "roles/run.invoker"
  member = "domain:ttec.com"
}

resource "google_compute_region_backend_service" "api_backend" {
  name                  = "api-backend"
  project               = local.application_project_id
  region                = "us-east4"
  load_balancing_scheme = "INTERNAL_MANAGED"
  protocol              = "HTTP"
  timeout_sec           = null
  health_checks = null

  backend {
    group = google_compute_region_network_endpoint_group.equip-returns-dev-api-neg.id
    balancing_mode = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
