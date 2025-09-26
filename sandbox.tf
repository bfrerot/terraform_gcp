resource "google_compute_instance" "instance-20250926-064029" {
  attached_disk {
    device_name = "disk-localssd-movingcastle1"
    mode        = "READ_WRITE"
  }

  boot_disk {
    auto_delete = true
    device_name = "instance-20250926-064029"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20250910"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = true

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
  }

  machine_type = "c2-standard-4"

  metadata = {
    enable-osconfig = "TRUE"
  }

  name = "instance-20250926-064029"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/carbon-gecko-472110-u1/regions/europe-west1/subnetworks/default"
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  scratch_disk {
    interface = "NVME"
  }

  service_account {
    email  = "778804135717-compute@developer.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  zone = "europe-west1-b"
}

module "ops_agent_policy" {
  source          = "github.com/terraform-google-modules/terraform-google-cloud-operations/modules/ops-agent-policy"
  project         = "carbon-gecko-472110-u1"
  zone            = "europe-west1-b"
  assignment_id   = "goog-ops-agent-v2-x86-template-1-4-0-europe-west1-b"
  agents_rule = {
    package_state = "installed"
    version = "latest"
  }
  instance_filter = {
    all = false
    inclusion_labels = [{
      labels = {
        goog-ops-agent-policy = "v2-x86-template-1-4-0"
      }
    }]
  }
}
