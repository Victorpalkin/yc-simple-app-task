output "dns_zone_id" {
    value = var.domain == "" ? var.zone_id : yandex_dns_zone.zone[0].id
}