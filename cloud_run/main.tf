resource "google_cloud_run_service" "default" {
  name     = "movingcastle-cr-01"
  location = "europe-west1"

  metadata {
    namespace = "carbon-gecko-472110-u1"
  }

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }
  }
}