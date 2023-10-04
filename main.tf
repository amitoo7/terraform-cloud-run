provider "google" {
  credentials = file("/Users/amitgadhia/work/mywork/test/cloud_run/hauntapp.json")
  project     = "hauntapp"
}

resource "google_cloud_run_service" "api-gateway" {
  name     = "api-gateway"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "nuvolar/api-gateway:latest"
        env {
          name  = "ORDER_SERVICE_URL"
          value = google_cloud_run_service.order-service.status[0].url
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "order-service" {
  name     = "order-service"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "nuvolar/order-service:latest"
        env {
          name  = "CUSTOMER_SERVICE_URL"
          value = google_cloud_run_service.customer-service.status[0].url
        }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service" "customer-service" {
  name     = "customer-service"
  location = "us-central1"
  template {
    spec {
      containers {
        image = "nuvolar/customer-service:latest"
        resources {
        limits = {
          cpu    = "1"
          memory = "1024Mi"  # Specify the desired CPU and memory resources here.
        }
      }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.api-gateway.location
  project     = google_cloud_run_service.api-gateway.project
  service     = google_cloud_run_service.api-gateway.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_policy" "noauth-order-service" {
  location    = google_cloud_run_service.order-service.location
  project     = google_cloud_run_service.order-service.project
  service     = google_cloud_run_service.order-service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_service_iam_policy" "noauth-customer-service" {
  location    = google_cloud_run_service.customer-service.location
  project     = google_cloud_run_service.customer-service.project
  service     = google_cloud_run_service.customer-service.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

## If using a custom domain, configure DNS settings.
#resource "google_dns_record_set" "custom_domain" {
#  name = "microservices"
#  type = "CNAME"
#  managed_zone = "your-dns-zone"
#  rrdatas = [google_cloud_run_service.microservice1.status[0].url, google_cloud_run_service.microservice2.status[0].url, google_cloud_run_service.microservice3.status[0].url]
#}
