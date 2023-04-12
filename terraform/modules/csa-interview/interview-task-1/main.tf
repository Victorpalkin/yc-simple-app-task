terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
  required_version = ">= 1.4.4"
}


locals {
  folder_id = var.folder_id == "" ? yandex_resourcemanager_folder.folder[0].id : var.folder_id
}

module "labels" {
  source = "../../yandex/labels"

  environment = var.environment
}

resource "yandex_resourcemanager_folder" "folder" {
  count = var.folder_id == "" ? 1 : 0

  cloud_id = var.cloud_id
  description = "${var.environment} folder for interview task"
  name = "${var.environment}-interview-folder"
  labels = module.labels.labels
}

resource "yandex_resourcemanager_folder_iam_binding" "folder_admin" {
  count = var.folder_id == "" ? 1 : 0

  folder_id = var.folder_id
  role      = "admin"
  members = [
    "userAccount:interview03"
  ]
}

module "network" {
    source = "../../yandex/vpc"

    folder_id = local.folder_id
    environment = var.environment
    vpc_name = var.vpc_name

    subnets = [
        {
            zone = "ru-central1-a"
            v4_cidr_blocks = ["10.0.0.0/20"]
        },
        {
            zone = "ru-central1-b"
            v4_cidr_blocks = ["10.0.16.0/20"]
        },
        {
            zone = "ru-central1-c"
            v4_cidr_blocks = ["10.0.32.0/20"]
        },
    ]
}

module "k8s_cluster" {
    source = "../../yandex/kubernetes-cluster"
    
    environment = var.environment
    folder_id = local.folder_id

    vpc_network_id = module.network.vpc_network_id
    master_subnets = module.network.subnets

    node_subnets = module.network.subnets

    depends_on = [
      module.network
    ]
}

module "registry" {
  source = "../../yandex/container-registry"

  registry_name = "demo-registry"
  environment = var.environment
  folder_id = local.folder_id
}

module "alb_ingress" {
  source = "../../yandex/alb-ingress"

  environment = var.environment
  folder_id = local.folder_id

  vpc_network_id = module.network.vpc_network_id
  cluster_id = module.k8s_cluster.cluster_id
  cluster_name = module.k8s_cluster.cluster_name

  static_ip_zone_id = module.network.subnets[0].zone

  depends_on = [
    module.k8s_cluster
  ]
}

# Provisioning of mysql cluster is currently omitted as this functionality is not implemented in the app
# module "mysql_cluster" {
#     source = "../../yandex/managed-mysql"

    # folder_id = local.folder_id
#     environment = var.environment

#     vpc_network_id = module.network.vpc_network_id
#     app_name = "interview03"
#     hosts_subnets = slice(module.network.subnets,0,2)
# }


module "dns"{
  source = "../../yandex/cloud-dns"

  environment = var.environment
  folder_id = local.folder_id

  domain = var.domain

  records = [{
    name = "@"
    data = [ module.alb_ingress.external_ip ]
    ttl = 200
    type = "A"
  }]
}


provider "kubernetes" {
  config_path = module.k8s_cluster.kubectl_config_map
}


module "demo_app_deployment" {
  source = "../../kubernetes/demo-app"

  namespace = "demo-app"
  subnet_ids = join(",", module.network.subnets.*.id)
  security_group_ids = join(",", [ module.k8s_cluster.cluster_security_group_id, module.alb_ingress.security_group_id ])
  external_ip_adress = module.alb_ingress.external_ip
  host = var.domain
  certificate_id = var.certificate_id
  
  depends_on = [
    module.alb_ingress
  ]
}