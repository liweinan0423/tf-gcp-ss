variable "project_id" {
  type = string
}

variable "ss_password" {
  type = string
}

locals {
  method = "chacha20-ietf-poly1305"
  port = 443
}

provider "template" {
  version = "~> 2.1"
}

provider "google" {
  project = var.project_id
  region  = "asia-east2"
  zone    = "asia-east2-a"
  version = "~> 3.41"
}

data "google_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

resource "google_compute_instance" "ss-server" {
  name         = "ss-server"
  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.name
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  tags = ["https-server"]

  metadata_startup_script = data.template_file.init.rendered
}

resource "google_compute_address" "static_ip" {
  name = "ss-static-ip"
}

resource "google_dns_managed_zone" "zone" {
  name = "ladder"
  dns_name = "ladder.li-weinan.com."
}

resource "google_dns_record_set" "dns" {
  name = "ladder.li-weinan.com."
  type = "A"
  ttl = 300
  managed_zone = "ladder"
  rrdatas = [google_compute_address.static_ip.address]
}

data "template_file" "init" {
  template = "${file("init.tpl")}"

  vars = {
    password = var.ss_password
    method = local.method
    port = local.port
  }
}

output "ss_server_ip" {
  value = google_compute_address.static_ip.address
}

output "ss_server_port" {
  value = 443
}

output "ss_encrypt_method" {
  value = local.method
}
