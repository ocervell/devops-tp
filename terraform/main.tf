terraform {
  required_version = ">= 1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# Configuration du provider GCP
provider "google" {
  project = var.project_id
  region  = var.region
}

# ─────────────────────────────────────────────
# APIs à activer
# ─────────────────────────────────────────────

resource "google_project_service" "run" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# ─────────────────────────────────────────────
# Compte de service pour Cloud Run
# ─────────────────────────────────────────────

resource "google_service_account" "cloudrun_sa" {
  account_id   = "cloudrun-sa"
  display_name = "Cloud Run Service Account (Terraform)"

  depends_on = [google_project_service.iam]
}

# Droits minimaux nécessaires (moindre privilège)
resource "google_project_iam_member" "cloudrun_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

resource "google_project_iam_member" "sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

# ─────────────────────────────────────────────
# Service Cloud Run
# ─────────────────────────────────────────────

resource "google_cloud_run_v2_service" "helloworld" {
  name     = "helloworld"
  location = var.region

  template {
    service_account = google_service_account.cloudrun_sa.email

    scaling {
      min_instance_count = 0
      max_instance_count = 5
    }

    containers {
      image = var.image

      env {
        name  = "APP_VERSION"
        value = var.app_version
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      # Cloud Run vérifie cet endpoint pour savoir si le conteneur est sain
      startup_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 5
        period_seconds        = 5
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        period_seconds    = 30
        failure_threshold = 3
      }
    }
  }

  depends_on = [
    google_project_service.run,
    google_service_account.cloudrun_sa,
  ]
}

# Rendre le service accessible publiquement
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = google_cloud_run_v2_service.helloworld.project
  location = google_cloud_run_v2_service.helloworld.location
  name     = google_cloud_run_v2_service.helloworld.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
