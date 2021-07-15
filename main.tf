provider "google" {
  project = "${var.project_id}"
}

# create a test dataset
resource "google_bigquery_dataset" "test_dataset" {
  dataset_id  = "${var.dataset_id}"
  description = "This is a test dataset"
  location    = "US"
}

# create a test table
resource "google_bigquery_table" "source_table" {
  dataset_id = google_bigquery_dataset.test_dataset.dataset_id
  table_id   = "${var.source_table}"
  schema = <<EOF
[
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The name"
  },
  {
    "name": "address",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "The address"
  }
]
EOF

}

# create a service account for BQ scheduled query to use
resource "google_service_account" "bq-scheduled-query-sa" {
  account_id   = "bq-scheduled-query-sa"
  display_name = "A service account to run bq scheduled query"
}

# grant bigquery admin role to the service account so that scheduled query can run
resource "google_project_iam_member" "bq-scheduled-query-sa-iam" {
  depends_on = [google_service_account.bq-scheduled-query-sa]
  project    = "${var.project_id}"
  role       = "roles/bigquery.admin"
  member     = "serviceAccount:${google_service_account.bq-scheduled-query-sa.email}"
}


data "google_project" "project" {}

resource "google_project_iam_member" "permissions" {
  role   = "roles/iam.serviceAccountShortTermTokenMinter"
  member = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-bigquerydatatransfer.iam.gserviceaccount.com"
}

# create a scheduled query
resource "google_bigquery_data_transfer_config" "query_config" {
  depends_on = [google_project_iam_member.permissions, google_project_iam_member.bq-scheduled-query-sa-iam]

  display_name           = "my-query"
  location               = "US"
  service_account_name   = google_service_account.bq-scheduled-query-sa.email
  data_source_id         = "scheduled_query"
  schedule               = "${var.schedule}"
  destination_dataset_id = google_bigquery_dataset.test_dataset.dataset_id
  params = {
    destination_table_name_template = "${var.target_table}"
    write_disposition               = "WRITE_APPEND"
    query                           =  "${file("${var.sql_file}")}"
  }
}
