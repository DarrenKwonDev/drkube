# 나중에 http only로 동작할 때만 살릴 것. 지금은 https만 사용함.

# https.tf와 동일하나 var.https 상태에 따라서 생성 여부 결정.
# vars.https 설정 키면 생성 안됨. 80으로 들어오는 건 443으로 redirect 처리할 것이기 때문.
# resource "google_compute_forwarding_rule" "http" {
#   count      = var.https ? 0 : 1
#   depends_on = [google_compute_subnetwork.proxy]
#   name       = "l7-xlb-forwarding-rule-http"
#   project    = google_compute_subnetwork.default.project
#   region     = google_compute_subnetwork.default.region
#   ip_protocol           = "TCP"
#   # Scheme required for a Regional External HTTP Load Balancer. This uses an external managed Envoy proxy
#   load_balancing_scheme = "EXTERNAL_MANAGED"
#   port_range            = "80"
#   target                = google_compute_region_target_http_proxy.default.id
#   network               = google_compute_network.default.id
#   ip_address            = google_compute_address.default.id
#   network_tier          = "STANDARD"
# }

# http만 사용함. https는 필요 없음.
# https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/compute_region_target_http_proxy
# resource "google_compute_region_target_http_proxy" "default" {
#   project = google_compute_subnetwork.default.project
#   region  = google_compute_subnetwork.default.region
#   name    = "l7-xlb-proxy-http"
#   url_map = google_compute_region_url_map.default.id
# }


