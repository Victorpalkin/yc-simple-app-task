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

resource "yandex_container_registry" "registry" {
  name = var.registry_name

  folder_id = var.folder_id
  labels = module.labels.labels
}