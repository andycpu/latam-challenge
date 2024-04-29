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

# resource "google_bigquery_table" "flights" {
#   dataset_id          = google_bigquery_dataset.latam_ds.dataset_id
#   table_id            = "flights"
#   #deletion_protection = false
#   external_data_configuration {
#     autodetect    = true
#     source_format = "GOOGLE_SHEETS"

#     google_sheets_options {
#       skip_leading_rows = 1
#     }

#     source_uris = [
#       "https://docs.google.com/spreadsheets/d/18MsF6UQbzjPq9GAtrIVxlkUWhAjO_8eKaj031J2uEFA",
#     ]
#   }
# }

resource "google_cloudfunctions_function" "get_flights" {
  name                = "get_flights"
  runtime             = "python39"
  #source_archive_url  = "gs://path/to/your/function/source.zip"
  entry_point         = "get_flights"
  timeout             = 60
  available_memory_mb = 256
  max_instances       = 1
  trigger_http        = "GET"

  source_repository {
    url = "https://source.developers.google.com/projects/your-project-id/repos/your-repo-id/moveable-aliases/master"
  }
#   event_trigger {
#     event_type = "http"
#     # Optionally, add other trigger settings like security_level, etc.
#   }

}