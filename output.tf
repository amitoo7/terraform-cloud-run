output "ip" {
  value = "${google_cloud_run_service.order-service.status[0].url}"
}
