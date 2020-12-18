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
}
provider "google" {
  project = var.project_id
  region  = "asia-east1"
  zone    = "asia-east1-a"
  version = "~> 3.41"
  alias   = "tw"
}
module "ss-instance" {
  source         = "./modules/ss-instance"
  ss_password    = var.ss_password
  instance_alias = "hk"
  providers = {
    google.gcp = google
  }
}
module "ss-instance-2" {
  source         = "./modules/ss-instance"
  ss_password    = var.ss_password
  instance_alias = "tw"
  providers = {
    google.gcp = google.tw
  }
}

data "google_dns_managed_zone" "zone" {
  name = "ladder"
}

resource "google_dns_record_set" "dns" {
  name         = "ladder.li-weinan.com."
  type         = "A"
  ttl          = 300
  managed_zone = "ladder"
  rrdatas      = [module.ss-instance.ip_address]
}

resource "google_dns_record_set" "dns-tw" {
  name         = "tw.ladder.li-weinan.com."
  type         = "A"
  ttl          = 300
  managed_zone = "ladder"
  rrdatas      = [module.ss-instance-2.ip_address]
}
