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

resource "yandex_vpc_address" "external" {
  folder_id = var.folder_id
  name = "alb-address"

  labels = module.labels.labels

  external_ipv4_address {
    zone_id = var.static_ip_zone_id
  }
}

resource "yandex_iam_service_account" "account" {
  name        = "ingress-controller-sa"
  description = "Ingress controller regional service account"
  folder_id = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_binding" "alb_editor" {
  # The service account is assigned the k8s.clusters.agent role.
  folder_id = var.folder_id
  role      = "alb.editor"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {

  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "certificate_downloader" {

  folder_id = var.folder_id
  role      = "certificate-manager.certificates.downloader"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "compute_viewer" {

  folder_id = var.folder_id
  role      = "compute.viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.account.id}"
  ]
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.account.id
  description        = "Static Access key for ingress controller"
}

resource "yandex_vpc_security_group" "alb_main_sg" {
  name        = "alb-sg"
  description = "Group rules ensure the basic performance of ALB"
  network_id  = var.vpc_network_id

  labels = module.labels.labels

  egress {
    protocol          = "ANY"
    description       = "Rule allows all outgoing traffic"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "TCP"
    description       = "Rules to access the load balancer"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 80
    to_port           = 80
  }
  ingress {
    protocol          = "TCP"
    description       = "Rules to access the load balancer"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 443
    to_port           = 443
  }
  ingress {
    protocol          = "TCP"
    description       = "Rule allows availability checks from load balancer's address range. It is required for the operation of a fault-tolerant cluster and load balancer services."
    predefined_target = "loadbalancer_healthchecks"
    from_port         = 0
    to_port           = 65535
  }
}



resource "null_resource" "auth_kubectl" {
  triggers = {
    cluster_id = var.cluster_id
  }

  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials ${var.cluster_name} --external --force"
  }

}

resource "null_resource" "get_key" {
  triggers = {
    cluster_id = var.cluster_id
  }

  provisioner "local-exec" {
    command = "yc iam key create --service-account-name ${yandex_iam_service_account.account.name} --output sa-key.json"
  }
  depends_on = [
    null_resource.auth_kubectl
  ]
}

resource "null_resource" "install_ingress" {
  triggers = {
    cluster_id = var.cluster_id
  }

  provisioner "local-exec" {
    command = "cat sa-key.json | helm registry login cr.yandex --username 'json_key' --password-stdin && helm pull oci://cr.yandex/yc-marketplace/yandex-cloud/yc-alb-ingress/yc-alb-ingress-controller-chart --version=v0.1.13 --untar && helm install --namespace default --set folderId=${var.folder_id} --set clusterId=${var.cluster_id} --set-file saKeySecretKey=sa-key.json yc-alb-ingress-controller ./yc-alb-ingress-controller-chart/"
  }

  depends_on = [
    null_resource.get_key
  ]

}

resource "null_resource" "delete_files" {
  triggers = {
    cluster_id = var.cluster_id
  }

  provisioner "local-exec" {
    command = "rm -rf sa-key.json yc-alb*"
  }

  depends_on = [
    null_resource.install_ingress
  ]    
}