terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
  required_version = ">= 1.4.4"
}


module "labels" {
    source = "../labels"

    environment = var.environment
}

resource "yandex_dns_zone" "zone" {
  folder_id = var.folder_id
  
  name        = "dns-public-zone"
  description = "${var.domain} Public Zone"

  labels = module.labels.labels

  zone             = "${var.domain}."
  public           = true
  
}

resource "yandex_dns_recordset" "set" {
  count = length(var.records)
  zone_id = yandex_dns_zone.zone.id
  name    = var.records[count.index].name
  type    = var.records[count.index].type
  ttl     = var.records[count.index].ttl
  data    = var.records[count.index].data

}