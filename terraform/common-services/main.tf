locals {
    folder_id = "b1gnf4rkjrgm97g2ei3k"
    cloud_id = "b1gdruhd9eunnnv8uaam"
    environment = "common"
    domain = "palkin.nl"
}


module "registry" {
  source = "../modules/yandex/container-registry"

  environment = local.environment
  registry_name = "demo-registry"
  folder_id = local.folder_id
}

module "dns" {
  source = "../modules/yandex/cloud-dns"

  environment = local.environment
  folder_id = local.folder_id
  domain = local.domain
  
}