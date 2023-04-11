terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
  required_version = ">= 1.4.4"
}


module "network" {
    source = "../../yandex/vpc"

    folder_id = var.folder_id
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

# module "k8s_cluster" {
#     source = "../../yandex/kubernetes-cluster"
    
#     environment = var.environment
#     folder_id = var.folder_id

#     vpc_network_id = module.network.vpc_network_id
#     master_subnets = module.network.subnets

#     node_subnets = module.network.subnets
# }


module "managed_instance_group_1" {
    source = "../../yandex/managed-instance-group"
    
    environment = var.environment
    folder_id = var.folder_id

    vpc_network_id = module.network.vpc_network_id
    subnets = module.network.subnets

    group_name = "demo-group-1"
    
}
# module "registry" {
#   source = "../../yandex/container-registry"

#   registry_name = "demo-registry"
#   environment = var.environment
#   folder_id = var.folder_id
# }

# module "alb_ingress" {
#   source = "../../yandex/alb-ingress"

#   environment = var.environment
#   folder_id = var.folder_id

#   cluster_endpoint = module.k8s_cluster.cluster_endpoint
#   cluster_ca_certificate = module.k8s_cluster.ca_certificate
#   cluster_id = module.k8s_cluster.cluster_id
# }

# module "mysql_cluster" {
#     source = "../../yandex/managed-mysql"

#     environment = var.environment

#     vpc_network_id = module.network.vpc_network_id
#     app_name = "interview03"
#     hosts_subnets = slice(module.network.subnets,0,2)
# }