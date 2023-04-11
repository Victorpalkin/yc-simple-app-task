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

resource "yandex_kubernetes_cluster" "k8s-regional" {
  name = var.cluster_name
  network_id = var.vpc_network_id
  folder_id = var.folder_id
  master {
    version =var.k8s_version
    regional {
      region = "ru-central1"
      dynamic "location" {
        for_each = var.master_subnets
        content {
          zone = location.value["zone"]
          subnet_id = location.value["id"]
        }
      }
    }
    security_group_ids = [yandex_vpc_security_group.k8s-main-sg.id]
  }
  service_account_id      = yandex_iam_service_account.myaccount.id
  node_service_account_id = yandex_iam_service_account.myaccount.id
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
  labels = module.labels.labels

  lifecycle {
    ignore_changes = [
      master
    ]
  }
}

resource "yandex_kubernetes_node_group" "node_group" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-regional.id}"
  name        = "${var.cluster_name}-node-group"
  description = "${var.cluster_name}-node-group"
  version     = var.k8s_version

  labels = module.labels.labels

  

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat                = true
      subnet_ids         = var.node_subnets.*.id
      security_group_ids = [ yandex_vpc_security_group.k8s-main-sg.id ]
    }


    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }

    scheduling_policy {
      preemptible = false
    }

    container_runtime {
      type = "Docker"
    }
  }

  scale_policy {
    fixed_scale {
      size = length(var.node_subnets)
    }
  }

  deploy_policy {
    max_expansion = 2
    max_unavailable = 1
  }

  allocation_policy {
    dynamic "location" {
      for_each = var.node_subnets
      content {
        zone = location.value["zone"]
      }
    }
    
  }


  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }
  }
}



resource "yandex_iam_service_account" "myaccount" {
  name        = "${var.cluster_name}-sa"
  description = "${var.cluster_name} regional service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  # The service account is assigned the k8s.clusters.agent role.
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  # The service account is assigned the vpc.publicAdmin role.
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # The service account is assigned the container-registry.images.puller role.
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}"
  ]
}

resource "yandex_kms_symmetric_key" "kms-key" {
  # A key for encrypting critical information, including passwords, OAuth tokens, and SSH keys.
  name              = "${var.cluster_name}-kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 year.

  labels = module.labels.labels
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
  role             = "viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.myaccount.id}",
  ]
}

resource "yandex_vpc_security_group" "k8s-main-sg" {
  name        = "${var.cluster_name}-main-sg"
  description = "Group rules ensure the basic performance of the cluster. Apply it to the cluster and node groups."
  network_id  = var.vpc_network_id

  labels = module.labels.labels
  ingress {
    protocol          = "TCP"
    description       = "Rule allows availability checks from load balancer's address range. It is required for the operation of a fault-tolerant cluster and load balancer services."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "Rule allows master-node and node-node communication inside a security group."
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  # ingress {
  #   protocol          = "ANY"
  #   description       = "Rule allows pod-pod and service-service communication. Specify the subnets of your cluster and services."
  #   v4_cidr_blocks    = concat(concat(var.node_subnets.*.v4_cidr_blocks))
  #   from_port         = 0
  #   to_port           = 65535
  # }
  ingress {
    protocol          = "ICMP"
    description       = "Rule allows debugging ICMP packets from internal subnets."
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    protocol          = "TCP"
    description       = "Rule allows incoming traffic from the internet to the NodePort port range. Add ports or change existing ones to the required ports."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  ingress {
    protocol          = "TCP"
    description       = "Rule allows incoming traffic from the internet to the NodePort port range. Add ports or change existing ones to the required ports."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "Rule allows all outgoing traffic. Nodes can connect to Yandex Container Registry, Yandex Object Storage, Docker Hub, and so on."
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}
