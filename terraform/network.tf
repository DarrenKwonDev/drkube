# VPC
resource "google_compute_network" "default" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
  project                 = var.project_id
  routing_mode = "REGIONAL" # GLOBAL, REGIONAL. 해당 프로젝트는 모두 REGIONAL로 설정
}