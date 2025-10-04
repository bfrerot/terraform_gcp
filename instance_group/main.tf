# Instance Template URL (à remplacer par votre URL exact)
# "projects/carbon-gecko-472110-u1/global/instanceTemplates/movingcastle-it-n2-standard-2-02"
variable "instance_template_url" {
  type    = string
  default = "projects/carbon-gecko-472110-u1/global/instanceTemplates/movingcastle-it-n2-standard-2-02"
}

resource "google_compute_region_instance_group_manager" "igm" {
  version {
    instance_template = var.instance_template_url
  }
  

  
  provider     = google-beta
  name         = "movingcastle-ig-2"
  region       = "europe-west9"
  distribution_policy_zones  = ["europe-west9-a", "europe-west9-b", "europe-west9-c"]
  base_instance_name = "movingcastle-ig-2"
  description        = "terraform"
  target_size = 3

  

  
  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "RESTART"
    instance_redistribution_type = "PROACTIVE"  # correspond à PROACTIVE
    max_unavailable_fixed = 3
  }

  standby_policy {
    mode = "MANUAL"
  }


  # Politique de lifecycle des instances (repairs, etc.)
  # Note: les noms exacts peuvent varier selon le provider;
  # si le bloc n'est pas accepté tel quel, ajustez selon le schéma du provider.
  # Instance lifecycle policy (REPAIR par défaut sur FAILED HEALTH CHECK, etc.)
  instance_lifecycle_policy {
    default_action_on_failure = "REPAIR"
    force_update_on_repair   = "NO"        # NO -> false (TRUE si nécessaire)
    on_failed_health_check   = "DEFAULT_ACTION"
  }

  
  # ListManagedInstancesResults et autres champs non supportés directement par le provider
  # ne pas inclure s'ils ne sont pas exposés par le provider.
}


resource "google_compute_region_autoscaler" "autoscaler" {
  provider = google-beta
  name     = "instance-group-1-autoscaler"
  region   = "europe-west9"
  

  # Lien vers le RIGM (self_link)
  target   = google_compute_region_instance_group_manager.igm.self_link

  autoscaling_policy {
    mode             = "ON"
    max_replicas   = 5
    min_replicas   = 3

    cpu_utilization {
      target = 0.6
      predictive_method  = "NONE"
    }
  }
}
