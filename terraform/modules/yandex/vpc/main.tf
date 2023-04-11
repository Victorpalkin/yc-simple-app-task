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

resource "yandex_vpc_network" "network" {
  name = var.vpc_name
  folder_id = var.folder_id

  labels = module.labels.labels
}

resource "yandex_vpc_gateway" "egress-gateway" {
  name = "egress-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "default" {
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.egress-gateway.id
  }
}

resource "yandex_vpc_subnet" "subnet" {
  count = length(var.subnets)

  v4_cidr_blocks = var.subnets[count.index].v4_cidr_blocks
  zone           = var.subnets[count.index].zone
  network_id     = yandex_vpc_network.network.id

  labels = module.labels.labels
}