variable "project_id" {
  type = string
}
variable "ss_password" {
  type = string
}

provider "google" {
  project = var.project_id
  region  = "asia-east2"
  zone    = "asia-east2-a"
  version = "~> 3.41"
  alias = "hk"
}
provider "google" {
  project = var.project_id
  region  = "asia-east1"
  zone    = "asia-east1-a"
  version = "~> 3.41"
  alias = "tw"
}

module "ss-instance" {
  source = "./modules/ss-instance"
  ss_password = var.ss_password
  providers = {
    google.gcp = google.hk
  }
}
module "ss-instance-2" {
  source = "./modules/ss-instance"
  ss_password = var.ss_password
  providers = {
    google.gcp = google.tw
  }
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
  rrdatas = [module.ss-instance.ip_address]
}
