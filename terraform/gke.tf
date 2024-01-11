
# GKE
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#logging_service
resource "google_container_cluster" "default" {
  provider           = google-beta
  project            = var.project_id
  name               = var.gke_cluster_name
  location           = var.zone
  initial_node_count = var.num_nodes
  networking_mode = "VPC_NATIVE"
  network         = google_compute_network.default.name
  subnetwork      = google_compute_subnetwork.default.name
 

  # On version 5.0.0+ of the provider, you must explicitly set deletion_protection=false (and run terraform apply to write the field to state) in order to destroy a cluster. It is recommended to not set this field (or set it to true) until you're ready to destroy.
  deletion_protection=false
 
 
  # stack driver 로깅 서비스를 끄자.
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster#logging_service
  logging_service = "none"

  node_config {
    spot         = true
    machine_type = var.machine_type
    disk_size_gb = var.disk_size
    tags         = ["${var.gke_cluster_name}"]
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/servicecontrol",
    ]
  }

  addons_config {
    http_load_balancing {
      # This needs to be enabled for the NEG to be automatically created for the ingress gateway svc
      disabled = false
    }
  }

  private_cluster_config {
    # Need to use private nodes for VPC-native GKE clusters
    enable_private_nodes = true
    # Allow private cluster Master to be accessible outside of the network
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.16/28"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "5.0.0.0/16"
    services_ipv4_cidr_block = "5.1.0.0/16"
  }

  default_snat_status {
    # More info on why sNAT needs to be disabled: https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#enable_pupis
    # This applies to VPC-native GKE clusters
    disabled = true
  }

  master_authorized_networks_config {
    cidr_blocks {
      # Because this is a private cluster, need to open access to the Master nodes in order to connect with kubectl
      cidr_block   = "0.0.0.0/0"
      display_name = "World"
    }
  }
}

resource "time_sleep" "wait_for_kube" {
  depends_on = [google_container_cluster.default]
  # GKE master endpoint may not be immediately accessible, resulting in error, waiting does the trick
  create_duration = "30s"
}

resource "null_resource" "local_k8s_context" {
  depends_on = [time_sleep.wait_for_kube]
  provisioner "local-exec" {
    # Update your local gcloud and kubectl credentials for the newly created cluster
    command = "for i in 1 2 3 4 5; do gcloud container clusters get-credentials ${var.gke_cluster_name} --project=${var.project_id} --zone=${var.zone} && break || sleep 60; done"
  }
}

