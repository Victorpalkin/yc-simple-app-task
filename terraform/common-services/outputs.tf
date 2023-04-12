output "container_registry_id" {
    value = module.registry.registry_id
    description = "The ID of the created container registry"
}

output "dns_zone_id" {
    value = module.dns.dns_zone_id
    description = "The ID of the created DNS zone"
}