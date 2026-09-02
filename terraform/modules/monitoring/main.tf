# Enable Monitoring API
resource "google_project_service" "monitoring" {
  project            = var.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

# Notification Channel (Email)
resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "FinTech Team Email"
  type         = "email"
  enabled      = true
  labels = {
    email_address = var.alert_email
  }

  depends_on = [google_project_service.monitoring]
}

# Dashboard
resource "google_monitoring_dashboard" "fintech_dashboard" {
  project = var.project_id
  dashboard_json = jsonencode({
    displayName = "FinTech API Dashboard"
    mosaicLayout = {
      columns = 12
      tiles = [
        {
          width  = 6
          height = 4
          widget = {
            title = "Request Count (5 min)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" resource.label.service_name=\"fintech-api\""
                    }
                  }
                }
              ]
            }
          }
        },
        {
          xPos   = 6
          width  = 6
          height = 4
          widget = {
            title = "Request Latency (ms)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\" resource.label.service_name=\"fintech-api\""
                    }
                  }
                }
              ]
            }
          }
        },
        {
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Error Rate (%)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" resource.label.service_name=\"fintech-api\" metric.labels.response_code_class=\"5xx\""
                    }
                  }
                }
              ]
            }
          }
        },
        {
          xPos   = 6
          yPos   = 4
          width  = 6
          height = 4
          widget = {
            title = "Execution Times (ms)"
            xyChart = {
              dataSets = [
                {
                  timeSeriesQuery = {
                    timeSeriesFilter = {
                      filter = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\" resource.label.service_name=\"fintech-api\""
                    }
                  }
                }
              ]
            }
          }
        }
      ]
    }
  })

  depends_on = [google_project_service.monitoring]
}

# Alert Policy: High Error Rate
resource "google_monitoring_alert_policy" "high_error_rate" {
  project               = var.project_id
  display_name          = "FinTech API - High Error Rate"
  combiner              = "OR"
  enabled               = true
  notification_channels = [google_monitoring_notification_channel.email.id]

  conditions {
    display_name = "Error rate > 5%"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/request_count\" resource.type=\"cloud_run_revision\" metric.labels.response_code_class=\"5xx\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 50

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  depends_on = [google_project_service.monitoring]
}

# Alert Policy: High Latency
resource "google_monitoring_alert_policy" "high_latency" {
  project               = var.project_id
  display_name          = "FinTech API - High Latency"
  combiner              = "OR"
  enabled               = true
  notification_channels = [google_monitoring_notification_channel.email.id]

  conditions {
    display_name = "P95 latency > 1000ms"
    condition_threshold {
      filter          = "metric.type=\"run.googleapis.com/request_latencies\" resource.type=\"cloud_run_revision\""
      duration        = "300s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1000

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_95"
      }
    }
  }

  depends_on = [google_project_service.monitoring]
}
