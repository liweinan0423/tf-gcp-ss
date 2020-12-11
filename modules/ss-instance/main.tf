locals {
  method = "chacha20-ietf-poly1305"
  port = 443
}

variable "ss_password" {
  type = string
}

provider "template" {
  version = "~> 2.1"
}

data "google_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}

data "template_file" "init" {
  template = "${file("modules/ss-instance/init.tpl")}"

  vars = {
    password = var.ss_password
    method = local.method
    port = local.port
  }
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

output "ip_address" {
  value = google_compute_address.static_ip.address
}
output "method" {
  value = local.method
}