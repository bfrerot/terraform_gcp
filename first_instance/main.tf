resource "google_compute_instance" "movingcastle-001" {
name = "test"
machine_type = "e2-micro"
zone = "europe-west9-a"
project = "carbon-gecko-472110-u1"

boot_disk {
    initialize_params {
        image = "debian-13"
    }
  }

network_interface { # comment
    network = "default"
  }
}

