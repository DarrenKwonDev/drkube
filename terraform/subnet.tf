
resource "google_compute_subnetwork" "default" {
  depends_on    = [google_compute_network.default]
  name          = "${var.gke_cluster_name}-subnet"
  project       = google_compute_network.default.project
  region        = var.region
  network       = google_compute_network.default.name
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_compute_subnetwork" "proxy" {
  depends_on = [google_compute_network.default]
  provider   = google
  name       = "proxy-only-subnet"
  ip_cidr_range = "11.129.0.0/23" 
  project       = google_compute_network.default.project
  region        = var.region
  network       = google_compute_network.default.id
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}
