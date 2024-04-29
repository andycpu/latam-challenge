variable "project_id" {
  description = "The ID of the GCP project"
  type = string
  default = "latam-challenge-421420"
}

variable "region" {
  description = "The region where resources will be deployed"
  type = string
  default = "southamerica-west1"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_bigquery_dataset" "latam_ds" {
  dataset_id    = "latam_ds"
  friendly_name = "LATAM Dataset"
  description   = "some description here"
  location      = var.region
}

resource "google_service_account" "cf_deployer_sa" {
  account_id   = "cf-deployer-sa"
  display_name = "Service Account to deploy CF"
}

resource "google_project_iam_member" "cf_deployer_sa_cloudfunctions_developer" {
  project = google_service_account.cf_deployer_sa.project
  role    = "roles/cloudfunctions.developer"
  member  = "serviceAccount:${google_service_account.cf_deployer_sa.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"  # Grant BigQuery Job User role
  member  = "serviceAccount:${google_service_account.cf_deployer_sa.email}"
}

resource "google_bigquery_table_iam_binding" "data_viewer" {
  project    = var.project_id
  dataset_id = "latam_ds"
  table_id   = "flights"
  role       = "roles/bigquery.dataViewer"  # Grant data viewer access to the table

  members = [
    "serviceAccount:${google_service_account.cf_deployer_sa.email}", 
  ]
}
