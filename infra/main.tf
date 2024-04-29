provider "google" {
  project = "latam-challenge-421420"
  region  = "southamerica-west1"
}

resource "google_bigquery_dataset" "latam_ds" {
  dataset_id    = "latam_ds"
  friendly_name = "LATAM Dataset"
  description   = "some description here"
  location      = "southamerica-west1"
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