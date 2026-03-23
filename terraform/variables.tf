variable "project_id" {
  description = "L'identifiant de votre projet GCP"
  type        = string
}

variable "region" {
  description = "La région GCP où déployer les ressources"
  type        = string
  default     = "europe-west1"
}

variable "app_version" {
  description = "La version de l'application à déployer"
  type        = string
  default     = "1.0.0"
}

variable "image" {
  description = "L'image Docker complète à déployer sur Cloud Run"
  type        = string
}
