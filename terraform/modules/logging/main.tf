# Enable Logging API
resource "google_project_service" "logging" {
  project            = var.project_id
  service            = "logging.googleapis.com"
  disable_on_destroy = false
}

# Log Sink for Cloud Run
resource "google_logging_project_sink" "fintech_api_logs" {
  name        = "fintech-api-logs"
  destination = "logging.googleapis.com/projects/${var.project_id}/logs/fintech-api"
  filter      = "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"fintech-api\""
  project     = var.project_id

  depends_on = [google_project_service.logging]
}

# Log Sink for Audit Logs
resource "google_logging_project_sink" "audit_logs" {
  name        = "fintech-audit-logs"
  destination = "logging.googleapis.com/projects/${var.project_id}/logs/audit"
  filter      = "protoPayload.methodName=~\"storage\\.\" OR protoPayload.methodName=~\"cloudsql\\.\""
  project     = var.project_id

  depends_on = [google_project_service.logging]
}

# Log-based Metric: API Errors
resource "google_logging_metric" "api_errors" {
  name    = "fintech_api_errors"
  filter  = "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"fintech-api\" httpRequest.status>=400"
  project = var.project_id

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key         = "status_code"
      value_type  = "STRING"
      description = "HTTP status code"
    }
  }

  depends_on = [google_project_service.logging]
}

# Log-based Metric: Database Queries
resource "google_logging_metric" "database_queries" {
  name    = "fintech_database_queries"
  filter  = "protoPayload.serviceName=\"cloudsql.googleapis.com\" protoPayload.methodName=\"cloudsql.instances.query\""
  project = var.project_id

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }

  depends_on = [google_project_service.logging]
}
