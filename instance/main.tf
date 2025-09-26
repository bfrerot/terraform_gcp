#****************************************************** compute ssd persistent disk parameters
resource "google_compute_disk" "ssd_movingcastlevm1" {
  name  = "disk-ssd-movingcastlevm1"
  type  = "pd-ssd"  # Or pd-standard, pd-balanced, etc.
  zone  = "europe-west9-b"  # Replace with your zone
  size  = 100  # Size in GB
}
#********************************************************************

#****************************************************** compute local-ssd disk parameters
resource "google_compute_disk" "localssd_movingcastlevm1" {
  name  = "disk-localssd-movingcastlevm1"
  type  = "pd-ssd"  # Or pd-standard, pd-balanced, etc.
  zone  = "europe-west9-b"  # Replace with your zone
  size  = 100  # Size in GB
}
#********************************************************************

#****************************************************** filestore parameters
resource "google_filestore_instance" "instance" {
  name     = "movingcastlfs"
  location = "europe-west9-b"
  tier     = "BASIC_HDD"

  file_shares {
    capacity_gb = 1024
    name        = "share1"
  }
#********************************************************************


  networks {
    network = "default"
    modes   = ["MODE_IPV4"]
  }
}


#*******************************************minimal instance creation
resource "google_compute_instance" "movingcastlevm1" {
  
  boot_disk {
    auto_delete = true
    device_name = "movingcastlevm1"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20250910"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }
#********************************************************************


#****************************************************** add persistent SSD disk test
  attached_disk {    
    source = google_compute_disk.ssd_movingcastlevm1.self_link
    device_name = "disk-ssd-movingcastlevm1"
    mode        = "READ_WRITE"
  }
#****************************************************** add LOCAL SSD disk test ==> instances types requirements !
  attached_disk {
    source = google_compute_disk.localssd_movingcastlevm1.self_link
    device_name = "disk-localssd-movingcastle1"
    mode        = "READ_WRITE"
  }
#********************************************************************


  can_ip_forward      = true
  deletion_protection = false
  description         = "terraform"
  enable_display      = false

  labels = {
    goog-ec-src           = "vm_add-tf"
    goog-ops-agent-policy = "v2-x86-template-1-4-0"
  }

  machine_type = "n2-standard-2"  # compliant with local ssd

  metadata = {
    enable-osconfig = "FALSE"
  }

  name = "movingcastlevm1"

  network_interface {
    access_config {
      network_tier = "STANDARD"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/carbon-gecko-472110-u1/regions/europe-west9/subnetworks/default"
  }

  scheduling {
    automatic_restart   = false
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "gcp-navet-terraform@carbon-gecko-472110-u1.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/devstorage.read_only", "https://www.googleapis.com/auth/logging.write", "https://www.googleapis.com/auth/monitoring.write", "https://www.googleapis.com/auth/service.management.readonly", "https://www.googleapis.com/auth/servicecontrol", "https://www.googleapis.com/auth/trace.append"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["https-server", "lb-health-check"]
  zone = "europe-west9-b"
}