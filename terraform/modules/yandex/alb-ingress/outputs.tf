output "security_group_id" {
    value = yandex_vpc_security_group.alb_main_sg.id
}

output "external_ip" {
    value = yandex_vpc_address.external.external_ipv4_address[0].address
}
