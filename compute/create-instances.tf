variable "gcp_region" { type = string }
variable "gcp_zone" { type = string }
variable "gcp_project" { type = string }
variable "gcp_auth_file" { type = string }
variable "bucket-name" { type = string }
variable "storage-class" { type = string }

terraform {
  backend "gcs" {
    bucket      = @bucket-name
    prefix      = "compute"
  }
}

provider "google" {
  credentials = file(var.gcp_auth_file)
  project     = var.gcp_project
  region      = var.gcp_region
}

resource "google_compute_instance" "airflow" {
  name         = "airflow"
  machine_type = "e2-small"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

    metadata_startup_script = "ls -la"
    tags = ["open-all"]
}

resource "google_compute_instance" "postgres_kafka_nifi" {
  name         = "postgres_kafka_nifi"
  machine_type = "e2-medium"
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

    metadata_startup_script = "ls -la"
    tags = ["open-all"]
}


resource "google_compute_firewall" "open-all" {
  name    = "default-allow-all-terraform"
  network = "default"

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["open-all"]
}

output "airflow" {
  value = "${google_compute_instance.airflow.network_interface.0.access_config.0.nat_ip}"
}

output "postgres_kafka_nifi" {
  value = "${google_compute_instance.postgres_kafka_nifi.network_interface.0.access_config.0.nat_ip}"
}
