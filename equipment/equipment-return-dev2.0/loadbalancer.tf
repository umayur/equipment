
 ## Internal Load baalancer
 #https configiration# URL map
resource "google_compute_region_url_map" "https" {
  name            = "ilb-https"
  project         = local.application_project_id
  region          = "us-east4"
  default_service = google_compute_region_backend_service.ui_backend.self_link
  host_rule {
    hosts        = ["returns-dev.ttec.com"]
    path_matcher = "path-matcher-1"
  }
  path_matcher {
    default_service = google_compute_region_backend_service.ui_backend.self_link
    name            = "path-matcher-1"
    path_rule {
      paths   = ["/api/*"]
      service = google_compute_region_backend_service.api_backend.self_link
    }
  }
}

resource "google_compute_region_ssl_policy" "ssl_policy" {
  name            = "ssl-policy"
  project         = local.application_project_id
  region          = "us-east4"
  profile         = "MODERN"
  min_tls_version = "TLS_1_2"
}

resource "google_compute_region_ssl_certificate" "ssl_cert" {
  name        = "ssl-cert"
  certificate = data.google_secret_manager_secret_version.return_ssl_crt.secret_data
  private_key = data.google_secret_manager_secret_version.return_ssl_key.secret_data
  project     = local.application_project_id
  region      = "us-east4"
}

resource "google_compute_region_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  project          = local.application_project_id
  region           = "us-east4"
  url_map          = google_compute_region_url_map.https.self_link
  ssl_policy       = google_compute_region_ssl_policy.ssl_policy.self_link
  ssl_certificates = [google_compute_region_ssl_certificate.ssl_cert.self_link]
  depends_on       = [google_compute_region_url_map.https]
}

resource "google_compute_forwarding_rule" "https_forward_rule" {
  name                  = "ilb-https-forward-rule"
  project               = local.application_project_id
  region                = "us-east4"
  allow_global_access   = true
  network_tier          = "PREMIUM"
  ip_address            = data.google_compute_address.internal-lb-ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  load_balancing_scheme = "INTERNAL_MANAGED"
  subnetwork            = google_compute_subnetwork.subnet-use4-equip-return-dev.self_link
  target                = google_compute_region_target_https_proxy.https_proxy.self_link
  depends_on            = [google_compute_region_target_https_proxy.https_proxy]
}



# http configuration
resource "google_compute_region_url_map" "url_map_http" {
  name            = "ilb-https-redirect"
  project         = local.application_project_id
  region          = "us-east4"
  default_service = google_compute_region_backend_service.ui_backend.self_link
  depends_on      = [google_compute_region_backend_service.ui_backend]
}

resource "google_compute_region_target_http_proxy" "http_proxy" {
  name       = "http-proxy"
  project    = local.application_project_id
  region     = "us-east4"
  url_map    = google_compute_region_url_map.url_map_http.self_link
  depends_on = [google_compute_region_url_map.url_map_http]
}

resource "google_compute_forwarding_rule" "http_forward_rule" {
  name                  = "ilb-http-forward-rule"
  project               = local.application_project_id
  region                = "us-east4"
  allow_global_access   = true
  network_tier          = "PREMIUM"
  ip_address            = data.google_compute_address.internal-lb-ip.address
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "INTERNAL_MANAGED"
  subnetwork            = google_compute_subnetwork.subnet-use4-equip-return-dev.self_link
  target                = google_compute_region_target_http_proxy.http_proxy.self_link
  depends_on            = [google_compute_region_target_http_proxy.http_proxy]
}