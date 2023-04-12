terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
  required_version = ">= 1.4.4"
}

provider "yandex" {
  cloud_id                 = local.cloud_id
  # folder_id                = local.folder_id
}



