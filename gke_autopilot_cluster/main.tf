resource "google_container_cluster" "movingcastle_gke_cluster_1" {
  name     = "movingcastle-gke-cluster-1"
  location = "europe-west9"

  # Activation du mode Autopilot
  enable_autopilot = true

  # Canal de release
  release_channel {
    channel = "REGULAR"
  }

  # Réseau et sous-réseau
  network    = "projects/carbon-gecko-472110-u1/global/networks/default"
  subnetwork = "projects/carbon-gecko-472110-u1/regions/europe-west9/subnetworks/default"

  # Allocation IP (CIDR pour le cluster)
  ip_allocation_policy {
    cluster_ipv4_cidr_block = "/17"
  }

  # Binary Authorization désactivé
  binary_authorization {
    evaluation_mode = "DISABLED"
  }

  # Scopes pour les nœuds (appliqué via node_config pour compatibilité, même en Autopilot)
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  # Configurations supplémentaires basées sur les flags
  # --enable-dns-access : Assumé comme activation de l'accès DNS privé (enable_private_nodes)
  # --no-enable-google-cloud-access : Désactivation de l'accès public (private_endpoint)
  private_cluster_config {
    enable_private_nodes    = true  # Pour activer l'accès DNS privé
    enable_private_endpoint = false # Désactive l'accès public si --no-enable-google-cloud-access l'implique
  }
}
