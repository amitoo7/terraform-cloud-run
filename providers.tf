// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("hauntapp.json")}"
 project     = "${var.gcp_project}"
 region      = "${var.gcp_region}"
}
