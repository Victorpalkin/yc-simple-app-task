output "vpc_name" {
  value = yandex_vpc_network.network.name
}

output "vpc_network_id" {
    value = yandex_vpc_network.network.id
}

output "subnets" {
    value = yandex_vpc_subnet.subnet
}