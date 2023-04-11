terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = ">= 0.89"
    }
  }
  required_version = ">= 1.4.4"
}


provider "helm" {
  kubernetes {
    # load_config_file = false

    host = var.cluster_endpoint
    cluster_ca_certificate = var.cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command = "yc"
      args = [
        "managed-kubernetes",
        "create-token",
        "--folder-id", var.folder_id,
      ]
    }
  }
}

module "labels" {
    source = "../labels"

    environment = var.environment
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

resource "helm_release" "yc-alb-ingress" {
  name       = "yc-alb-ingress"
  repository = "oci://cr.yandex/yc-marketplace/"
  chart      = "yandex-cloud/yc-alb-ingress/yc-alb-ingress-controller-chart"
  version    = "v0.1.16"
  create_namespace = true
#   values = [
#     "${file("values.yaml")}"
#   ]
  set_sensitive {
    name = "saKeySecretKey"
    value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  }
  set {
    name  = "folderId"
    value = var.folder_id
  }

  set {
    name  = "clusterId"
    value = var.cluster_id
  }
}