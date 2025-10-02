# Ressource pour le template d'instance
resource "google_compute_instance_template" "movingcastle-it-n2-standard-2-02" {
  name = "movingcastle-it-n2-standard-2-02"  # Préfixe pour le nom du template (GCP ajoutera un suffixe unique)
  description = "Template with SSD persistent disk and local SSD"
  machine_type = "n2-standard-2" 
  region = "projects/carbon-gecko-472110-u1/regions/europe-west9" # problem, the region remains at global

# Disks
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
    disk_type    = "pd-balanced"
    disk_size_gb = 10
    mode         = "READ_WRITE"
    type         = "PERSISTENT"
  }

  disk {
    mode            = "READ_WRITE" 
    auto_delete     = true         
    disk_type       = "pd-ssd"
    disk_size_gb    = 10
    type            = "PERSISTENT"
  }

  disk {
    mode            = "READ_WRITE"
    type            = "SCRATCH"
    auto_delete     = true
    disk_type       = "local-ssd"
    interface       = "NVME"
    disk_size_gb    = 375
  }

# Network
  network_interface {
    network = "default"
    access_config {}
  }

scheduling {
    automatic_restart          = false
    instance_termination_action = "STOP"  # Pour les Spot : arrête l'instance au lieu de la supprimer
    on_host_maintenance        = "TERMINATE"  # Requis pour local SSD lors de maintenance host
    provisioning_model         = "SPOT"  # Instances Spot (préemptibles)
    preemptible                = true
    
    # Block nested pour la récupération des local SSD (timeout de 1 heure = 3600 secondes)
    local_ssd_recovery_timeout {
      seconds = 3600  # Entier, sans guillemets
      # nanos = 0     # Optionnel, pour plus de précision (défaut 0)
    }
    
    # OMIT on_instance_stop_action car non supporté en Terraform stable.
    # Si besoin, GCP appliquera le défaut (discard local SSD sur STOP).
  }

# Tags 
  tags = ["test"]

}
