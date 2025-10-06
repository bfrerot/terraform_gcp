# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = "carbon-gecko-472110-u1"
  name                       = "gke-test-1"
  region                     = "europe-west9"
  zones                      = ["europe-west9-a", "europe-west9-b", "europe-west9-c"]
  network    = "projects/carbon-gecko-472110-u1/global/networks/default"
  subnetwork = "projects/carbon-gecko-472110-u1/regions/europe-west9/subnetworks/default"
  ip_range_pods              = "/17"
#  ip_range_services          = "default"
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false
  dns_cache                  = false

  node_pools = [
    {
      name                        = "default-node-pool"
      machine_type                = "e2-medium"
      node_locations              = "europe-west9-a,europe-west9-b"
      min_count                   = 1
      max_count                   = 100
      local_ssd_count             = 0
      spot                        = false
      disk_size_gb                = 100
      disk_type                   = "pd-standard"
      image_type                  = "COS_CONTAINERD"
      enable_gcfs                 = false
      enable_gvnic                = false
      logging_variant             = "DEFAULT"
      auto_repair                 = true
      auto_upgrade                = true
      service_account             = "gcp-navet-terraform@carbon-gecko-472110-u1.iam.gserviceaccount.com"
      preemptible                 = false
      initial_node_count          = 80
#      accelerator_count           = 1
#      accelerator_type            = "nvidia-l4"
#      gpu_driver_version          = "LATEST"
#      gpu_sharing_strategy        = "TIME_SHARING"
#      max_shared_clients_per_gpu = 2
    },
  ]

  node_pools_oauth_scopes = {
    all = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}

    default-node-pool = {
      node-pool-metadata-custom-value = "my-node-pool"
    }
  }

  node_pools_taints = {
    all = []

    default-node-pool = [
      {
        key    = "default-node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []

    default-node-pool = [
      "default-node-pool",
    ]
  }
}