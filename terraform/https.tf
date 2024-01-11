
# 80 tcp가 오면 redirect 처리
# LB의 프론트엔드
resource "google_compute_forwarding_rule" "redirect" {
  count = var.https ? 1 : 0
  depends_on = [google_compute_subnetwork.proxy]

  network    = google_compute_network.default.id
  name       = "l7-xlb-forwarding-rule-http-redirect"
  project    = google_compute_subnetwork.default.project
  region     = google_compute_subnetwork.default.region

  # inbound rule
  ip_protocol = "TCP"
  port_range  = "80"
  ip_address  = google_compute_address.default.id

  # send to
  target = google_compute_region_target_http_proxy.redirect.id

  # Scheme required for a Regional External HTTP Load Balancer. This uses an external managed Envoy proxy
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "STANDARD"
}

resource "google_compute_region_target_http_proxy" "redirect" {
  name    = "l7-xlb-proxy-http-redirect"
  project = google_compute_subnetwork.default.project
  region  = google_compute_subnetwork.default.region
  url_map = google_compute_region_url_map.redirect.id
}

resource "google_compute_region_url_map" "redirect" {
  project = google_compute_subnetwork.default.project
  region  = google_compute_subnetwork.default.region
  name    = "regional-l7-xlb-map-http-redirect"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

# ----------------------------------------------------------------

# 443 tcp 들어오는 https 처리
resource "google_compute_forwarding_rule" "https" {
  count       = var.https ? 1 : 0
  depends_on  = [google_compute_subnetwork.proxy]
  
  name        = "l7-xlb-forwarding-rule-https"
  network               = google_compute_network.default.id
  project     = google_compute_subnetwork.default.project
  region      = google_compute_subnetwork.default.region

  port_range            = "443"
  ip_protocol = "TCP"
  ip_address            = google_compute_address.default.id

  # Scheme required for a Regional External HTTPS Load Balancer. This uses an external managed Envoy proxy
  target                = google_compute_region_target_https_proxy.default.id
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "STANDARD"
}

resource "google_compute_region_ssl_certificate" "default" {
  project     = google_compute_subnetwork.default.project
  region      = google_compute_subnetwork.default.region
  name        = var.ssl_cert_name
  description = "SSL certificate for l7-xlb-proxy-https"
  private_key = file(var.ssl_cert_key)
  certificate = file(var.ssl_cert_crt)
}

# https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/compute_ssl_certificate#example-usage---ssl-certificate-target-https-proxies
# 443 tcp 들어오는 https 처리하는 target https proxy
resource "google_compute_region_target_https_proxy" "default" {
  project          = google_compute_subnetwork.default.project
  region           = google_compute_subnetwork.default.region
  name             = "l7-xlb-proxy-https"
  url_map          = google_compute_region_url_map.default.id
  ssl_certificates = [google_compute_region_ssl_certificate.default.id]
}


resource "google_compute_region_url_map" "default" {
  depends_on      = [google_compute_region_backend_service.default]
  project         = google_compute_subnetwork.default.project
  region          = google_compute_subnetwork.default.region
  name            = "regional-l7-xlb-map-http"
  default_service = google_compute_region_backend_service.default.id

  # Pulled from example: https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/compute_region_url_map#example-usage---region-url-map-l7-ilb-path
  # This is Envoy-specific configuration
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_region_backend_service.default.id
    path_rule {
      service = google_compute_region_backend_service.default.id
      paths   = ["/"]
      route_action {
        # Because the ingress gateways run on spot nodes, there might be connection draining issues or other connection issues
        # while the node/pod are shutting down. With the retry mechanism, the traffic should shift to the other instance of the
        # ingress gateway on the retries.
        retry_policy {
          num_retries = 5
          per_try_timeout {
            seconds = 1
          }
          retry_conditions = ["5xx", "deadline-exceeded", "connect-failure"]
        }
      }
    }
  }
}